# variables.tf
# "ఏ ఏ inputs వాడతాం" అని define చేయడం

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project name — resources కి tag అవుతుంది"
  type        = string
  default     = "financial-tracker"
}

variable "app_port" {
  description = "App runs on this port"
  type        = number
  default     = 80
}