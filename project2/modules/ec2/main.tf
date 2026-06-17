# modules/ec2/main.tf


# ── ALB Security Group ────────────────────────────
resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── EC2 Security Group ────────────────────────────
resource "aws_security_group" "web" {
  name   = "${var.project_name}-web-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── Load Balancer ─────────────────────────────────
resource "aws_lb" "web" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [var.public_subnet_1, var.public_subnet_2]
}

resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path              = "/"
    healthy_threshold = 2
    interval          = 30
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ── Launch Template ───────────────────────────────
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = var.instance_profile    # S3 access కోసం
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx

    # S3 నుండి app files download చేయి
    aws s3 cp s3://${var.bucket_id}/index.html /usr/share/nginx/html/index.html
    aws s3 cp s3://${var.bucket_id}/style.css  /usr/share/nginx/html/style.css
    aws s3 cp s3://${var.bucket_id}/app.js     /usr/share/nginx/html/app.js

    systemctl reload nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-web" }
  }
}

# ── Auto Scaling Group ────────────────────────────
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = [var.public_subnet_1, var.public_subnet_2]
  target_group_arns   = [aws_lb_target_group.web.arn]
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-server"
    propagate_at_launch = true
  }
}