from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.mgmt.datafactory.models import PipelineRun, CreateRunResponse


def create_adf_pipeline_run(adf_client: DataFactoryManagementClient, resource_group_name: str,
                            data_factory_name: str, pipeline_name: str, parameters: dict) -> CreateRunResponse:
    """
    Triggers an ADF pipeline.

    :param adf_client:              DataFactoryManagementClient
    :param resource_group_name:     Resource Group Name
    :param data_factory_name:       Data Factory Name
    :param pipeline_name:           Pipeline Name
    :param parameters:              Dictionary of parameters to pass in
    :return:
        CreateRunResponse
    """
    response = adf_client.pipelines.create_run(resource_group_name, data_factory_name, pipeline_name,
                                               parameters=parameters)
    return response


def get_adf_pipeline_run(adf_client: DataFactoryManagementClient, resource_group_name: str,
                         data_factory_name: str, run_id: str) -> PipelineRun:
    """
    Gets a data factory pipeline
    :param adf_client:
    :param resource_group_name:
    :param data_factory_name:
    :param run_id:
    :return:
        PipelineRun
    """
    return adf_client.pipeline_runs.get(
        resource_group_name=resource_group_name,
        factory_name=data_factory_name,
        run_id=run_id,
    )


def check_adf_pipeline_in_complete_state(adf_client: DataFactoryManagementClient, resource_group_name: str,
                                         data_factory_name: str, run_id: str) -> bool:
    """
    Gets the pipeline run. Returns True if pipeline in completed state or False if pipeline not in complete state.

    :param adf_client:              DataFactoryManagementClient
    :param resource_group_name:     Resource Group Name
    :param data_factory_name:       Data Factory Name
    :param run_id:                  Pipeline run ID
    :return:
        bool
    """
    pipeline_run = adf_client.pipeline_runs.get(
        resource_group_name=resource_group_name,
        factory_name=data_factory_name,
        run_id=run_id)
    return pipeline_run.status in ["Succeeded", "Failed"]
