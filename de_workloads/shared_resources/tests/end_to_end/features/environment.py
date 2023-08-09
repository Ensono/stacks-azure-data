from behave import use_fixture

from fixtures import azure_adls_clean_up

TEST_DIRECTORY_NAME = "shared_steps_test"


def before_scenario(context, scenario):
    use_fixture(azure_adls_clean_up, context, TEST_DIRECTORY_NAME)
