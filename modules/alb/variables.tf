# Project name used for naming and tagging resources.
variable "project" {
  description = "The name of the project"
  type        = string
}

# VPC ID where both ALBs and target groups are created.
variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed"
  type        = string
}

# First web subnet ID used by the public ALB.
variable "web_subnet_1_id" {
  description = "The ID of the first subnet for the web servers"
  type        = string
}

# Second web subnet ID used by the public ALB.
variable "web_subnet_2_id" {
  description = "The ID of the second subnet for the web servers"
  type        = string
}

# First app subnet ID used by the internal ALB.
variable "app_subnet_1_id" {
  description = "The ID of the first subnet for the app servers"
  type        = string
}

# Second app subnet ID used by the internal ALB.
variable "app_subnet_2_id" {
  description = "The ID of the second subnet for the app servers"
  type        = string
}

# Security group ID attached to the internal ALB.
variable "internal_alb_sg_id" {
  description = "The ID of the security group for the internal ALB"
  type        = string
}

# Security group ID attached to the public ALB.
variable "pub_alb_sg_id" {
  description = "The ID of the security group for the public ALB"
  type        = string
}

# Web server instance ID to register in web target group.
variable "web_server_instance_id" {
  description = "The ID of the web server instance"
  type        = string
}

# App server instance ID to register in app target group.
variable "app_server_instance_id" {
  description = "The ID of the app server instance"
  type        = string
}
