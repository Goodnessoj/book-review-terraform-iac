# Security group used by web instances.
variable "web_sg_id" {
  description = "Security group ID for web servers"
  type        = string
}

# Security group used by app instances.
variable "app_sg_id" {
  description = "Security group ID for app servers"
  type        = string
}

# First subnet where web instances can be deployed.
variable "web_subnet_1_id" {
  description = "Subnet ID for the first web subnet"
  type        = string
}

# Second subnet where web instances can be deployed.
variable "web_subnet_2_id" {
  description = "Subnet ID for the second web subnet"
  type        = string
}

# First subnet where app instances can be deployed.
variable "app_subnet_1_id" {
  description = "Subnet ID for the first app subnet"
  type        = string
}

# Second subnet where app instances can be deployed.
variable "app_subnet_2_id" {
  description = "Subnet ID for the second app subnet"
  type        = string
}

# SSH key pair name attached to EC2 instances.
variable "keyname" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

# Instance size for the web tier EC2 server.
variable "web_instance_type" {
  description = "The instance type for web servers"
  type        = string
}

# Instance size for the app tier EC2 server.
variable "app_instance_type" {
  description = "The instance type for app servers"
  type        = string
}

# Project name used for tagging and naming resources.
variable "project" {
  description = "The name of the project"
  type        = string
}