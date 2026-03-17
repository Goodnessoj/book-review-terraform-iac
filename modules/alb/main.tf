# Internal ALB that receives traffic from the web tier.
resource "aws_lb" "internal_alb" {
    name               = "private-alb"
    internal           = true
    load_balancer_type = "application"  
    security_groups    = [var.internal_alb_sg_id]
    subnets            = [var.app_subnet_1_id, var.app_subnet_2_id]

    tags = {
        Name = "internal-alb"
    }
}

# Target group for app instances behind the internal ALB.
resource "aws_lb_target_group" "app_tg" {
    name     = "app-tg"
    port     = 3001
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "app-tg"
        Project = var.project
    }
}

# Listener for internal ALB traffic on port 3001.
resource "aws_lb_listener" "app_http" {
    load_balancer_arn = aws_lb.internal_alb.arn
    port              = 3001
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}

# Public ALB that receives internet traffic on port 80.
resource "aws_lb" "public_alb" {
    name               = "public-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [var.pub_alb_sg_id]
    subnets            = [var.web_subnet_1_id, var.web_subnet_2_id]

    tags = {
        Name = "public-alb" 
    }
}
  
# Target group for web instances behind the public ALB.
resource "aws_lb_target_group" "web_tg" {
    name     = "web-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
    tags = {
        Name = "web-tg"
    }
}

# Listener for public ALB traffic on port 80.
resource "aws_lb_listener" "web_http" {
    load_balancer_arn = aws_lb.public_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.web_tg.arn
    }
}

# Registers the web server instance in the web target group.
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.web_server_instance_id
  port             = 80
}

# Registers the app server instance in the app target group.
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.app_server_instance_id
  port             = 3001
}