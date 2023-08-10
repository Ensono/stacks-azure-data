from behave import use_fixture

from fixtures import azure_adls_clean_up

SQL_DB_INGEST_DIRECTORY_NAME = "Ingest_AzureSql_Demo"


def before_scenario(context, scenario):
    use_fixture(azure_adls_clean_up, context, SQL_DB_INGEST_DIRECTORY_NAME)
