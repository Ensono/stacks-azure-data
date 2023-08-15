from behave import use_fixture
from behave.model import Scenario
from behave.runner import Context

from fixtures import azure_adls_clean_up

TEST_DIRECTORY_NAME = "shared_steps_test"


def before_scenario(context: Context, scenario: Scenario):
    """Behave before scenario steps."""
    use_fixture(azure_adls_clean_up, context, TEST_DIRECTORY_NAME)
