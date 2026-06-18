# environments/dev/outputs.tf

output "app_url" {
  value = module.ec2.alb_url
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}

output "db_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "environment" {
  value = var.env
}
output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_url" {
  value = module.eks.ecr_url
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}