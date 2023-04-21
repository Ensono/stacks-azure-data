import os
from datetime import datetime
from behave import *
from azure.identity import DefaultAzureCredential
from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.storage.filedatalake import DataLakeServiceClient
import polling2
from constants import (
    RAW_CONTAINER_NAME,
    ADLS_URL,
    SQL_DB_INGEST_DIRECTORY_NAME,
    SUBSCRIPTION_ID,
    DATA_FACTORY_NAME,
    RESOURCE_GROUP_NAME
)


credential = DefaultAzureCredential()
adf_client = DataFactoryManagementClient(credential, SUBSCRIPTION_ID)
adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)


def check_pipeline_in_complete_state(adf_client: DataFactoryManagementClient, resource_group_name: str,
                                     data_factory_name: str, run_id: str) -> bool:
    pipeline_run = adf_client.pipeline_runs.get(
        resource_group_name=resource_group_name,
        factory_name=data_factory_name,
        run_id=run_id)
    return pipeline_run.status in ["Succeeded", "Failed"]


@given('the ADF pipeline {pipeline_name} has been triggered')
def step_impl(context, pipeline_name: str):
    current_datetime = datetime.now().strftime("%Y%m%d%H%M%S")
    run_id = f"automated_test_run_{current_datetime}"
    run_response = adf_client.pipelines.create_run(RESOURCE_GROUP_NAME, DATA_FACTORY_NAME, pipeline_name,
                                                   parameters={"run_id": run_id})
    context.run_id = run_response.run_id

@step('the ADF pipeline {pipeline_name} has finished with state {state}')
def step_impl(context, pipeline_name: str, state: str):

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


@then('the data from the SQL database have been copied into ADLS')
def step_impl(context):
    filesystem_client = adls_client.get_file_system_client(RAW_CONTAINER_NAME)
    paths = filesystem_client.get_paths(SQL_DB_INGEST_DIRECTORY_NAME)
    for path in paths:
        print(path.name)