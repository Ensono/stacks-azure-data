from pysparkle.pysparkle_cli import cli


def call_pysparkle_entrypoint():
    cli(["data_quality", "--config_path", "data_quality/ingest_dq.json"], standalone_mode=False)


if __name__ == "__main__":
    call_pysparkle_entrypoint()
