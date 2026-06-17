# modules/s3/outputs.tf

output "bucket_id"           { value = aws_s3_bucket.app.id }
output "bucket_arn"          { value = aws_s3_bucket.app.arn }
output "instance_profile"    { value = aws_iam_instance_profile.ec2_profile.name }