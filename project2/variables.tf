# variables.tf

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "project_name" {
  type    = string
  default = "financial-tracker"
}

variable "min_servers" {
  type    = number
  default = 2
}

variable "max_servers" {
  type    = number
  default = 4
}

variable "db_password" {
  type      = string
  sensitive = true
}