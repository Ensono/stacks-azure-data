from pysparkle.pysparkle_cli import cli


def call_pysparkle_entrypoint():
    """Execute silver processing in Pysparkle."""
    cli(["silver", "--dataset-name", "movies_dataset"], standalone_mode=False)


if __name__ == "__main__":
    call_pysparkle_entrypoint()
