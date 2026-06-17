# environments/prod/variables.tf

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "project_name" {
  type    = string
  default = "financial-tracker"
}

variable "min_servers" {
  type    = number
  default = 3
}

variable "max_servers" {
  type    = number
  default = 10
}

variable "env" {
  type    = string
  default = "prod"
}

variable "db_password" {
  type      = string
  sensitive = true
}