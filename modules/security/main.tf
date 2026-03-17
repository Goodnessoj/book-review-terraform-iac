# Security group for the public ALB.
resource "aws_security_group" "pub_alb_sg" {

  name_prefix = "pub-alb-sg-"
  description = "Security group for public ALB in the book review app"
  vpc_id      = var.book_review_vpc_id


  tags = {
    Name = "${var.project}-pub-alb-sg"
  }
}

# Allows inbound HTTP traffic from the internet to the public ALB.
resource "aws_security_group_rule" "pub_alb_sg_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pub_alb_sg.id
}
# Allows outbound traffic from the public ALB security group.
resource "aws_security_group_rule" "pub_alb_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pub_alb_sg.id
}


# Security group for web tier EC2 instances.
resource "aws_security_group" "web_sg" {

  name_prefix = "web-sg-"
  description = "Security group for web servers in the book review app"
  vpc_id      = var.book_review_vpc_id


  tags = {
    Name = "${var.project}-web-sg"
  }
}

# Allows web traffic from the public ALB to web servers.
resource "aws_security_group_rule" "web_sg_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.pub_alb_sg.id
  security_group_id        = aws_security_group.web_sg.id
}

# Allows SSH access to web servers.
resource "aws_security_group_rule" "web_sg_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.web_sg.id
}

# Allows outbound traffic from web servers.
resource "aws_security_group_rule" "web_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Security group for the internal ALB.
resource "aws_security_group" "internal_alb_sg" {

  name_prefix = "internal-alb-sg"
  description = "Security group for internal ALB in the book review app"
  vpc_id      = var.book_review_vpc_id
  tags = {
    Name = "${var.project}-internal-alb-sg"
  }
}

# Allows app traffic from web tier to the internal ALB.
resource "aws_security_group_rule" "internal_alb_sg_inbound" {
  type              = "ingress"
  from_port         = 3001
  to_port           = 3001
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.internal_alb_sg.id
}
# Allows outbound traffic from the internal ALB.
resource "aws_security_group_rule" "internal_alb_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal_alb_sg.id
}

# Security group for app tier EC2 instances.
resource "aws_security_group" "app_sg" {

  name_prefix = "app-sg-"
  description = "Security group for app servers in the book review app"
  vpc_id      = var.book_review_vpc_id
  tags = {
    Name = "${var.project}-app-sg"
  }
}

# Allows app traffic from the internal ALB to app servers.
resource "aws_security_group_rule" "app_sg_inbound" {
  type              = "ingress"
  from_port         = 3001
  to_port           = 3001
  protocol          = "tcp"
  source_security_group_id = aws_security_group.internal_alb_sg.id
  security_group_id        = aws_security_group.app_sg.id
}

# Allows SSH access to app servers from web tier.
resource "aws_security_group_rule" "app_sg_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.app_sg.id
}

# Allows outbound traffic from app servers.
resource "aws_security_group_rule" "app_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

# Security group for the database tier.
resource "aws_security_group" "db_sg" {

  name_prefix = "db-sg-"
  description = "Security group for database servers in the book review app"
  vpc_id      = var.book_review_vpc_id
  tags = {
    Name = "${var.project}-db-sg"
  }
}

# Allows MySQL traffic from app servers to the database.
resource "aws_security_group_rule" "db_sg_inbound" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
}
