from pysparkle.pysparkle_cli import cli


def call_pysparkle_entrypoint():
    """Execute data quality activity in Pysparkle."""
    cli(
        [
            "data-quality",
            "--config-path",
            "ingest/Ingest_AzureSql_Example/data_quality/ingest_dq.json",
        ],
        standalone_mode=False,
    )


if __name__ == "__main__":
    call_pysparkle_entrypoint()
