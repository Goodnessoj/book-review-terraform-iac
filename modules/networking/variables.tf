# Project name used for naming and tagging network resources.
variable "project" {
  description = "The name of the project"
  type        = string
}

# CIDR range for the VPC.
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

# CIDR range for web subnet 1.
variable "web_subnet_1_cidr" {
  description = "The CIDR block for the first web subnet"
  type        = string
}

# CIDR range for web subnet 2.
variable "web_subnet_2_cidr" {
  description = "The CIDR block for the second web subnet"
  type        = string
}

# CIDR range for app subnet 1.
variable "app_subnet_1_cidr" {
  description = "The CIDR block for the first app subnet"
  type        = string
}

# CIDR range for app subnet 2.
variable "app_subnet_2_cidr" {
  description = "The CIDR block for the second app subnet"
  type        = string
}

# CIDR range for database subnet 1.
variable "db_subnet_1_cidr" {
  description = "The CIDR block for the first db subnet"
  type        = string
}

# CIDR range for database subnet 2.
variable "db_subnet_2_cidr" {
  description = "The CIDR block for the second db subnet"
  type        = string
}
