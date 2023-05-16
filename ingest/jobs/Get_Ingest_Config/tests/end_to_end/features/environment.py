from behave import use_fixture

from constants import SQL_DB_INGEST_DIRECTORY_NAME
from fixtures import azure_adls_clean_up


def before_scenario(context, scenario):
    use_fixture(azure_adls_clean_up, context, SQL_DB_INGEST_DIRECTORY_NAME)
