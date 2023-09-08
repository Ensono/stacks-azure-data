setup_dev_environment:
	echo "PYTHONPATH=." > .env
	poetry install
	poetry self add poetry-dotenv-plugin
	poetry shell
	poetry update
	pre-commit install

test:
	python -m pytest de_workloads/ingest/Ingest_AzureSql_Example/tests/unit
	python -m pytest de_workloads/data_processing/silver/tests/unit
	python -m pytest datastacks/tests/unit
	python -m pytest pysparkle/tests/unit

test_e2e:
	behave de_workloads/ingest/Ingest_AzureSql_Example/tests/end_to_end/features/azure_data_ingest.feature

pre_commit:
	pre-commit run --all-files
