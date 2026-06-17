# modules/s3/main.tf

resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-app-files-p2"
  tags   = { Name = var.project_name }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.app.id
  key          = "index.html"
  source       = "${var.app_path}/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.app_path}/index.html")
}

resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.app.id
  key          = "style.css"
  source       = "${var.app_path}/style.css"
  content_type = "text/css"
  etag         = filemd5("${var.app_path}/style.css")
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.app.id
  key          = "app.js"
  source       = "${var.app_path}/app.js"
  content_type = "application/javascript"
  etag         = filemd5("${var.app_path}/app.js")
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3-read-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.app.arn,
        "${aws_s3_bucket.app.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}