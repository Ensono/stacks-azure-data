from pysparkle.data_quality.main import data_quality_main


CONFIG_CONTAINER = "config"


if __name__ == "__main__":
    data_quality_main(config_path="data_processing/silver/data_quality/silver_dq.json", container_name=CONFIG_CONTAINER)
