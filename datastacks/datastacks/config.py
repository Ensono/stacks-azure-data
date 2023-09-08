from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field

INGEST_TEMPLATE_FOLDER = "Ingest_SourceType_SourceName"


class DataSourceType(Enum):
    """Enum containing supported data source types."""

    AZURE_SQL = "azure_sql"


class TriggerFrequency(Enum):
    """Enum containing supported trigger frequencies."""

    MINUTE = "Minute"
    HOUR = "Hour"
    DAY = "Day"
    WEEK = "Week"
    MONTH = "Month"


class IngestConfig(BaseModel):
    """Pydantic definitions for data ingest workload generation config."""

    class Config:
        """Configuration for Pydantic model."""

        use_enum_values = True

    dataset_name: str = Field(
        description="Dataset name, used to derive pipeline and linked service names, e.g. AzureSql_Example."
    )
    pipeline_description: str = Field(
        description="Description of the pipeline to be created. Will be used for the Data Factory pipeline description."
    )
    data_source_type: DataSourceType = Field(description="Data source type.")

    key_vault_linked_service_name: str = Field(
        default="ls_KeyVault", description="Name of the Key Vault linked service in Data Factory."
    )
    data_source_password_key_vault_secret_name: str = Field(
        description="Secret name of the data source password in Key Vault."
    )
    data_source_connection_string_variable_name: str = Field(description="Variable name for the connection string.")

    ado_variable_groups_nonprod: list[str] = Field(
        description="List of required variable groups in non-production environment."
    )
    ado_variable_groups_prod: list[str] = Field(
        description="List of required variable groups in production environment."
    )

    default_arm_deployment_mode: Optional[str] = Field(
        default="Incremental", description="Deployment mode for terraform."
    )

    window_start_default: Optional[date] = Field(
        default="2010-01-01", description="Default window start date in the Data Factory pipeline."
    )
    window_end_default: Optional[date] = Field(
        default="2010-01-31", description="Default window end date in the Data Factory pipeline."
    )

    bronze_container: str = Field(default="raw", description="Name of container for Bronze data.")
    silver_container: Optional[str] = Field(default="staging", description="Name of container for Silver data.")
    gold_container: Optional[str] = Field(default="curated", description="Name of container for Gold data.")

    trigger_start: Optional[datetime] = Field(
        default="2010-01-01T00:00:00Z", description="Start datetime for Data Factory pipeline trigger."
    )
    trigger_end: Optional[datetime] = Field(
        default="2011-12-31T23:59:59Z", description="End datetime for Data Factory pipeline trigger."
    )
    trigger_frequency: Optional[TriggerFrequency] = Field(
        default="Month", description="Frequency for the Data Factory pipeline trigger."
    )
    trigger_interval: Optional[int] = Field(
        default=1, description="Interval value for the Data Factory pipeline trigger."
    )
    trigger_delay: Optional[str] = Field(
        default="02:00:00", description="Delay between Data Factory pipeline triggers, formatted HH:mm:ss"
    )
