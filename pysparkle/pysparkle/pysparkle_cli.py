# Entrypoint for PySparkle application.
import click

from pysparkle.gold import gold_main
from pysparkle.silver import silver_main


@click.group()
def cli():
    pass


@click.command()
@click.argument('service-principal-secret', type=str, default=None)
def silver(service_principal_secret):
    silver_main(service_principal_secret)


@click.command()
@click.option('--partitions', '-p', default=2)
def gold(partitions):
    gold_main(partitions)


cli.add_command(silver)
cli.add_command(gold)


if __name__ == '__main__':
    cli(standalone_mode=False)
