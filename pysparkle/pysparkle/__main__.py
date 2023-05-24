import click

from .gold import gold_main
from .silver import silver_main


@click.group()
def cli():
    pass


@click.command()
@click.argument('partitions', type=int)
def silver(partitions):
    silver_main(partitions)


@click.command()
def gold():
    gold_main()


cli.add_command(silver)
cli.add_command(gold)


if __name__ == "__main__":
    cli()
