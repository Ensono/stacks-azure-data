from pysparkle.pysparkle_cli import cli


def call_pysparkle_entrypoint():
    """Execute data quality activity in Pysparkle."""
    cli(
        [
            "data-quality",
            "--config-path",
            "data_processing/silver/data_quality/silver_dq.json",
        ],
        standalone_mode=False,
    )


if __name__ == "__main__":
    call_pysparkle_entrypoint()
