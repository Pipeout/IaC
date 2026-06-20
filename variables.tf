variable "aws_region" {
  type        = string
  description = "Default region"
}

variable "pipeout_bucket_name" { type = string }

variable "airflow_ui_port" {
  default = 8080
}

variable "airflow_log_port" {
  default = 8793
}

variable "airflow_cpu" {
  default = 2048
}

variable "airflow_memory" {
  default = 4096
}

variable "airflow_image" {
  type = string
}

variable "model_training_cpu" {
  default = 2048
}

variable "model_training_memory" {
  default = 4096
}

variable "model_training_image" {
  type = string
}

variable "feature_engineering_cpu" {
  default = 2048
}

variable "feature_engineering_memory" {
  default = 4096
}

variable "feature_engineering_image" {
  type = string
}

variable "mlflow_port" {
  default = 5000
}

variable "mlflow_cpu" {
  default = 1024
}

variable "mlflow_memory" {
  default = 2048
}

variable "mlflow_image" {
  type = string
}


variable "preprocessing_cpu" {
  default = 2048
}

variable "preprocessing_memory" {
  default = 4096
}

variable "preprocessing_image" {
  type = string
}
