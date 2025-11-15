terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  default_for_az    = true
}

# Get latest Ubuntu LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for SSM access
resource "aws_iam_role" "ssm_role" {
  name = "${var.instance_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.instance_name}-ssm-role"
  }
}

# Attach SSM managed policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.instance_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
  vpc_id      = data.aws_vpc.default.id

  # Port 3000
  ingress {
    description = "Port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 8000
  ingress {
    description = "Port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 8080
  ingress {
    description = "Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# EBS Volume
resource "aws_ebs_volume" "data_volume" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.instance_name}-data-volume"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = var.instance_type
  subnet_id                            = data.aws_subnet.default.id
  vpc_security_group_ids               = [aws_security_group.instance_sg.id]
  iam_instance_profile                 = aws_iam_instance_profile.ssm_profile.name
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    auto_shutdown_minutes = var.auto_shutdown_minutes
    ssh_public_key        = var.ssh_public_key
    ebs_volume_id         = aws_ebs_volume.data_volume.id
    setup_user_script     = file("${path.module}/../hetzner/setup-user.sh")
  })

  tags = {
    Name = var.instance_name
  }
}

# Attach EBS Volume to Instance
resource "aws_volume_attachment" "data_volume_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.main.id
}
