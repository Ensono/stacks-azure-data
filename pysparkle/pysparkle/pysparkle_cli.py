# Entrypoint for PySparkle application.
import click

from pysparkle.gold import gold_main
from pysparkle.silver import silver_main
from pysparkle.data_quality.data_quality import data_quality_main


@click.group()
def cli():
    pass


@click.command()
def silver():
    """Bronze to Silver processing.

    Requires environment variable AZURE_CLIENT_SECRET (Service Principal Secret).
    """
    silver_main()


@click.command()
@click.option('--partitions', '-p', default=2)
def gold(partitions):
    """Silver to Gold processing."""
    gold_main(partitions)


dq_config = {
    "container_name": "staging",
    "dataset_name": "movies_metadata",
    "expectation_suite_name": "movies_metadata_suite",
    "validation_config": [{
        "column_name": "adult",
        "expectations": [{
            "expectation_type": "expect_column_values_to_not_be_null",
            "expectation_kwargs": {}
        }]
    }]
}

@click.command()
def data_quality():
    """Data Quality Checking."""
    data_quality_main(dq_config)


cli.add_command(silver)
cli.add_command(gold)
cli.add_command(data_quality)


if __name__ == '__main__':
    cli(standalone_mode=False)
