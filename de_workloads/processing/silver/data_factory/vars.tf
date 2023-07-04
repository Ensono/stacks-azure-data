variable "data_factory" {
  type        = string
  default     = "amido-stacks-dev-euw-rs"
  description = "Azure Data Factory name"
}

variable "data_factory_resource_group_name" {

  type        = string
  default     = "amido-stacks-dev-euw-de"
  description = "Azure Data Factory resource group name"
}

variable "include_data_quality" {
  type        = bool
  description = "Include data quality step in pipeline"
}
