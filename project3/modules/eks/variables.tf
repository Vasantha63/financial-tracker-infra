# modules/eks/variables.tf

variable "project_name" { type = string }
variable "region"       { type = string }
variable "vpc_id"       { type = string }
variable "subnet_ids"   { type = list(string) }
variable "node_type"    { type = string default = "t3.medium" }
variable "min_nodes"    { type = number default = 1 }
variable "max_nodes"    { type = number default = 3 }
variable "desired_nodes"{ type = number default = 2 }