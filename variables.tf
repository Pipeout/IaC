variable "aws_region" {
  type        = string
  description = "Default region"
}

variable "pipeout_bucket_name" { type = string }

variable "airflow_ui_port" {
  type        = string
  description = "UI port for airflow"
  sensitive   = true
  default     = 8080
}

variable "airflow_log_port" {
  type        = string
  description = "API port for airflow"
  sensitive   = true
  default     = 8793
}


variable "airflow_cpu" {
  default = 512
}

variable "airflow_memory" {
  default = 1024
}

variable "airflow_image" {
  type = string
}

variable "model_training_cpu" {
  default = 512
}

variable "model_training_memory" {
  default = 1024
}

variable "model_training_image" {
  type = string
}

variable "feature_engineering_cpu" {
  default = 256
}

variable "feature_engineering_memory" {
  default = 512
}

variable "feature_engineering_image" {
  type = string
}

variable "mlflow_port" {
  default = 5000
}

variable "mlflow_cpu" {
  default = 256
}

variable "mlflow_memory" {
  default = 512
}

variable "mlflow_image" {
  type = string
}
