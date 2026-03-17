variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string

}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string

}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "web_subnet_1_cidr" {
  description = "The CIDR block for the first web subnet"
  type        = string
}

variable "web_subnet_2_cidr" {
  description = "The CIDR block for the second web subnet"
  type        = string
}
variable "app_subnet_1_cidr" {
  description = "The CIDR block for the first app subnet"
  type        = string
}

variable "app_subnet_2_cidr" {
  description = "The CIDR block for the second app subnet"
  type        = string
}
variable "db_subnet_1_cidr" {
  description = "The CIDR block for the first db subnet"
  type        = string
}
variable "db_subnet_2_cidr" {
  description = "The CIDR block for the second db subnet"
  type        = string
}

variable "keyname" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}
variable "web_instance_type" {
  description = "The instance type for web servers"
  type        = string
}
variable "app_instance_type" {
  description = "The instance type for app servers"
  type        = string
}


variable "allocated_storage" {
  description = "The allocated storage for the RDS database in gigabytes"
  type        = number
}
variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}
variable "engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}
variable "engine_version" {
  description = "The version of the database engine to use"
  type        = string
}
variable "instance_class" {
  description = "The instance class for the RDS database (e.g., db.t3.micro)"
  type        = string
}
variable "username" {
  description = "The master username for the RDS database"
  type        = string
}
variable "password" {
  description = "The master password for the RDS database"
  type        = string
}
