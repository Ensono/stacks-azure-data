from behave import use_fixture
from behave.model import Scenario
from behave.runner import Context

from datastacks.behave.fixtures import azure_adls_clean_up
from datastacks.constants import BRONZE_CONTAINER_NAME

SQL_DB_INGEST_DIRECTORY_NAME = "ingest_azure_sql_example"


def before_scenario(context: Context, scenario: Scenario):
    """Behave before scenario steps."""
    use_fixture(azure_adls_clean_up, context, BRONZE_CONTAINER_NAME, SQL_DB_INGEST_DIRECTORY_NAME)
