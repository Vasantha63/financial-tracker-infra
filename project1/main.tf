# terraform/main.tf
# ఇక్కడ HTML లేదు — Infrastructure మాత్రమే
# App code S3 లో పెట్టి download చేస్తాం


# ── S3 Bucket — App files store చేయడానికి ──────
resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-app-files"
  tags   = { Name = var.project_name }
}

# S3 లో index.html upload
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.app.id
  key          = "index.html"
  source       = "./app/index.html"     # Local file path
  content_type = "text/html"
  etag         = filemd5("./app/index.html")  # File change అయితే re-upload
}

# S3 లో style.css upload
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.app.id
  key          = "style.css"
  source       = "./app/style.css"
  content_type = "text/css"
  etag         = filemd5("./app/style.css")
}

# S3 లో app.js upload
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.app.id
  key          = "app.js"
  source       = "./app/app.js"
  content_type = "application/javascript"
  etag         = filemd5("./app/app.js")
}

# ── VPC ─────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── IAM Role — EC2 కి S3 access ─────────────────
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
  name = "${var.project_name}-profile"
  role = aws_iam_role.ec2_role.name
}

# ── Security Group ───────────────────────────────
resource "aws_security_group" "web" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg" }
}

# ── EC2 Instance ─────────────────────────────────
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # user_data లో HTML లేదు
  # S3 నుండి app files download చేయడం మాత్రమే
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx

    # S3 నుండి app files download చేయి
    aws s3 cp s3://${aws_s3_bucket.app.id}/index.html /usr/share/nginx/html/index.html
    aws s3 cp s3://${aws_s3_bucket.app.id}/style.css  /usr/share/nginx/html/style.css
    aws s3 cp s3://${aws_s3_bucket.app.id}/app.js     /usr/share/nginx/html/app.js

    systemctl reload nginx
  EOF

  tags = { Name = "${var.project_name}-server" }
}