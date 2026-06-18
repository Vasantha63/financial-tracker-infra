# modules/eks/outputs.tf

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "ecr_url" {
  value = aws_ecr_repository.app.repository_url
}

output "node_group_name" {
  value = aws_eks_node_group.main.node_group_name
}