install_dev_environment:
	echo "PYTHONPATH=." > .env
	poetry self add poetry-dotenv-plugin
	poetry shell
	pre-commit install
	poetry update

test:
	pytest tests/unit/

pre_commit:
	pre-commit run --all-files
