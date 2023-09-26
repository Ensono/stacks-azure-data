import pytest
from unittest.mock import Mock
from azure.mgmt.datafactory import DataFactoryManagementClient
from azure.mgmt.datafactory.models import CreateRunResponse, PipelineRun
from datastacks.azure.data_factory import create_adf_pipeline_run, get_adf_pipeline_run

# Mocking the create_run method of DataFactoryManagementClient
@pytest.fixture
def mock_create_run():
    return Mock()


# Test case for create_adf_pipeline_run function
def test_create_adf_pipeline_run(mock_create_run):
    # Mock the create_run method
    mock_create_run.return_value = CreateRunResponse(
        run_id="12345678",
        # status="Queued",
        # response={"key": "value"},
    )

    # Create a mock DataFactoryManagementClient instance
    mock_adf_client = Mock()
    mock_adf_client.pipelines.create_run = mock_create_run

    # Define input parameters
    resource_group_name = "my_resource_group"
    data_factory_name = "my_data_factory"
    pipeline_name = "my_pipeline"
    parameters = {"param1": "value1", "param2": "value2"}

    # Call the function to be tested
    result = create_adf_pipeline_run(
        mock_adf_client,
        resource_group_name,
        data_factory_name,
        pipeline_name,
        parameters,
    )

    assert result.run_id == "12345678"
    mock_create_run.assert_called_once_with(
        resource_group_name, data_factory_name, pipeline_name, parameters=parameters
    )


# @pytest.fixture
# def mock_pipeline_runs_get():
#     return Mock(return_value=PipelineRun(
#         run_id="12345678",
#         status="InProgress",
#         response={"key": "value"},
#     ))

# # Test case for get_adf_pipeline_run function
# def test_get_adf_pipeline_run(mock_pipeline_runs_get):
#     # Create a mock DataFactoryManagementClient instance
#     mock_adf_client = Mock()
#     mock_adf_client.pipeline_runs.get = mock_pipeline_runs_get

#     # Define input parameters
#     resource_group_name = "my_resource_group"
#     data_factory_name = "my_data_factory"
#     run_id = "12345678"

#     # Call the function to be tested
#     result = get_adf_pipeline_run(
#         mock_adf_client,
#         resource_group_name,
#         data_factory_name,
#         run_id,
#     )

#     # Assertions
#     assert result.run_id == "12345678"  # Check if the function returns the expected response

#     # Verify that the pipeline_runs.get method was called with the correct arguments
#     mock_pipeline_runs_get.assert_called_once_with(
#         resource_group_name=resource_group_name,
#         factory_name=data_factory_name,
#         run_id=run_id,
#     )
