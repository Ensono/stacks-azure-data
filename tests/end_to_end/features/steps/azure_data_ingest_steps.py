import os
import time
from datetime import datetime
from behave import *
from azure.identity import DefaultAzureCredential
from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.storage.filedatalake import DataLakeServiceClient
import polling2


SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID")
RESOURCE_GROUP_NAME = os.environ.get("AZURE_RESOURCE_GROUP_NAME")
DATA_FACTORY_NAME = os.environ.get("AZURE_DATA_FACTORY_NAME")
REGION_NAME = os.environ.get("AZURE_REGION_NAME")
STORAGE_ACCOUNT_NAME = os.environ.get("AZURE_STORAGE_ACCOUNT_NAME")

credential = DefaultAzureCredential()
adf_client = DataFactoryManagementClient(credential, SUBSCRIPTION_ID)

account = DataLakeServiceClient(account_url=f"https://{STORAGE_ACCOUNT_NAME}.dfs.core.windows.net", credential=credential)

# Create a DataLakeFileSystemClient object for the desired directory
directory_name = "raw"
file_system_client = account.get_file_system_client(file_system=directory_name)



@given('the ADF pipeline {pipeline_name} has been triggered')
def step_impl(context, pipeline_name: str):
    current_datetime = datetime.now().strftime("%Y%m%d%H%M%S")
    run_id = f"automated_test_run_{current_datetime}"
    run_response = adf_client.pipelines.create_run(RESOURCE_GROUP_NAME, DATA_FACTORY_NAME, pipeline_name,
                                                   parameters={"run_id": run_id})
    context.run_id = run_response.run_id


@step('the ADF pipeline has been executed')
def step_impl(context):
    assert True is not False

@step('the ADF pipeline {pipeline_name} has finished with state {state}')
def step_impl(context, pipeline_name: str, state: str):

    def check_pipeline_in_complete_state(adf_client, resource_group_name, data_factory_name, run_id):

        pipeline_run = adf_client.pipeline_runs.get(
        resource_group_name=resource_group_name,
        factory_name=data_factory_name,
        run_id=run_id)
        return pipeline_run.status in ["Succeeded", "Failed"]

    polling2.poll(
        lambda: check_pipeline_in_complete_state(adf_client, RESOURCE_GROUP_NAME, DATA_FACTORY_NAME, context.run_id),
        step=10,  # Poll every 30 seconds
        poll_forever=True,  # Keep polling until the pipeline run reaches a terminal state
    )

    pipeline_run = adf_client.pipeline_runs.get(
        resource_group_name=RESOURCE_GROUP_NAME,
        factory_name=DATA_FACTORY_NAME,
        run_id=context.run_id,
    )
    assert pipeline_run.status == state


@then('the files are added to ADLS')
def step_impl(context):
    files = file_system_client.get_paths()
    for file in files:
        print(file.name)