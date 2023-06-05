from pysparkle.pysparkle_cli import cli


def call_entrypoint():
    cli(['silver', '--dataset-name', 'movies_dataset'], standalone_mode=False)


if __name__ == '__main__':
    call_entrypoint()
