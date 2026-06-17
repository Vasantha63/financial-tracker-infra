# modules/ec2/variables.tf

variable "project_name"    { type = string }
variable "vpc_id"          { type = string }
variable "public_subnet_1" { type = string }
variable "public_subnet_2" { type = string }
variable "instance_type"   { type = string }
variable "min_size"        { type = number }
variable "max_size"        { type = number }
variable "bucket_id"       { type = string }
variable "instance_profile"{ type = string }