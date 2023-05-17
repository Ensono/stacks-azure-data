import json
import uuid
from datetime import datetime

import polling2
from azure.identity import DefaultAzureCredential
from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.storage.filedatalake import DataLakeServiceClient
from behave import *

from constants import (
     ADLS_URL,
     ADLS_CONFIG_URL,
     AZURE_SUBSCRIPTION_ID,
     AZURE_DATA_FACTORY_NAME,
     AZURE_RESOURCE_GROUP_NAME,
     AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX
)
from utils.azure.data_factory import check_adf_pipeline_in_complete_state, get_adf_pipeline_run, create_adf_pipeline_run
from utils.azure.adls import all_files_present_in_adls

credential = DefaultAzureCredential()
adf_client = DataFactoryManagementClient(credential, AZURE_SUBSCRIPTION_ID)
adls_client = DataLakeServiceClient(account_url=ADLS_URL, credential=credential)
adls_config_client = DataLakeServiceClient(account_url=ADLS_CONFIG_URL, credential=credential)


@given('the ADF pipeline {pipeline_name} has been triggered with {parameters}')
def trigger_adf_pipeline(context, pipeline_name: str, parameters: str):
    context.start_time = datetime.now()
    parameters = json.loads(parameters)
    correlation_id = f'automated_test_{uuid.uuid4()}'
    context.correlation_id = correlation_id
    parameters.update({'correlation_id': f'{AUTOMATED_TEST_OUTPUT_DIRECTORY_PREFIX}_{uuid.uuid4()}'})

    run_response = create_adf_pipeline_run(adf_client, AZURE_RESOURCE_GROUP_NAME, AZURE_DATA_FACTORY_NAME, pipeline_name,
                                           parameters=parameters)
    context.run_id = run_response.run_id


@step('I poll the pipeline every {seconds} seconds until it has completed')
def poll_adf_pipeline(context, seconds: str):
    polling2.poll(
        lambda: check_adf_pipeline_in_complete_state(adf_client, AZURE_RESOURCE_GROUP_NAME, AZURE_DATA_FACTORY_NAME,
                                                     context.run_id),
        step=int(seconds),
        timeout=300
    )


@step('the ADF pipeline {pipeline_name} has finished with state {state}')
def pipeline_has_finished_with_state(context, pipeline_name: str, state: str):
    pipeline_run = get_adf_pipeline_run(adf_client,
                                        AZURE_RESOURCE_GROUP_NAME,
                                        AZURE_DATA_FACTORY_NAME,
                                        context.run_id)
    assert pipeline_run.status == state


@then('the files {output_files} are present in the ADLS container {container_name} in the directory '
      '{directory_name}')
def check_all_files_present_in_adls(context, output_files, container_name, directory_name):
    expected_files_list = json.loads(output_files)
    assert all_files_present_in_adls(adls_client, container_name, directory_name, expected_files_list)


@step('the ADF pipeline completed in less than {seconds} seconds')
def check_adf_pipeline_completion_time(context, seconds):
    end_time = datetime.now()
    time_diff = (end_time - context.start_time).total_seconds()
    assert time_diff < float(seconds)


@then('the config files {output_files} are present in the ADLS container {container_name} in the directory '
      '{directory_name}')
def check_config_files_present_in_adls(context, output_files, container_name, directory_name):
    expected_files_list = json.loads(output_files)
    assert all_files_present_in_adls(adls_config_client, container_name, directory_name, expected_files_list)
