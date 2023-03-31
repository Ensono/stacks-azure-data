install_dev_environment:
	echo "PYTHONPATH=." > .env
	poetry self add poetry-dotenv-plugin
	poetry shell
	poetry update
	pre-commit install

test:
	python -m pytest tests/unit/

pre_commit:
	pre-commit run --all-files
