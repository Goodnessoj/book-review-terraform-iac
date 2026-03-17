# Web tier EC2 instance placed in the public subnet.
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_instance_type
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.keyname
  subnet_id              = var.web_subnet_1_id

  associate_public_ip_address = true

  tags = {
    Name = "${var.project}-web-server"
  }
}

# App tier EC2 instance placed in the private subnet.
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.app_instance_type
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.keyname
  subnet_id              = var.app_subnet_1_id

  associate_public_ip_address = false

  tags = {
    Name = "${var.project}-app-server-1"
  }
}

# Retrieves AWS account metadata for contextual use.
data "aws_caller_identity" "current" {}


# Resolves the latest Ubuntu 24.04 AMI for EC2 instances.
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

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }


  filter {
    name   = "state"
    values = ["available"]
  }
}