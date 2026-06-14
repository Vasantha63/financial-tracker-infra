# outputs.tf
# Apply అయిన తర్వాత ఇవి terminal లో print అవుతాయి

output "server_public_ip" {
  description = "EC2 server IP"
  value       = aws_instance.web.public_ip
}

output "app_url" {
  description = "Financial Tracker app URL"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "SSH to server"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${aws_instance.web.public_ip}"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}