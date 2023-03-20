install_dev_environment:
	echo "PYTHONPATH=." > .env
	poetry self add poetry-dotenv-plugin
	poetry shell
	poetry update

test:
	pytest tests/unit/
