variable "data_factory" {
  type        = string
  description = "Azure Data Factory name"
}

variable "data_factory_resource_group_name" {
  type        = string
  description = "Azure Data Factory resource group name"
}

variable "include_data_quality" {
  type        = bool
  description = "Include data quality step in pipeline"
}

variable "arm_deployment_mode" {
  type        = string
  description = "Deployment mode for any ARM resources"
  default     = "Incremental"
}
