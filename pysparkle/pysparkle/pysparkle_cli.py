# Entrypoint for PySparkle application.
import click

from pysparkle.gold import gold_main
from pysparkle.silver import silver_main


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


cli.add_command(silver)
cli.add_command(gold)


if __name__ == '__main__':
    cli(standalone_mode=False)
