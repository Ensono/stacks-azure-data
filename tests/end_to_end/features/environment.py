from fixtures import azure_adls_clean_up
from behave import use_fixture


def before_scenario(context, scenario):
    use_fixture(azure_adls_clean_up, context)
