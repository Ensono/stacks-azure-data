from behave import use_fixture
from behave.model import Scenario
from behave.runner import Context

from stacks.data.behave.fixtures import azure_blob_config_prepare

DATA_TARGET_DIRECTORY = "shared_steps_test"
DATA_LOCAL_DIRECTORY = "de_workloads/shared_resources/tests/data/ingest_sources"


def before_feature(context: Context, scenario: Scenario):
    """Behave before scenario steps."""
    use_fixture(azure_blob_config_prepare, context, DATA_TARGET_DIRECTORY, DATA_LOCAL_DIRECTORY)
