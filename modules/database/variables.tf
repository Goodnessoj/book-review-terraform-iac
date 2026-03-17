# First private subnet ID for the database subnet group.
variable "db_subnet_1_id" { 
  description = "The ID of the first subnet for the RDS database"
  type        = string
  
}
# Second private subnet ID for the database subnet group.
variable "db_subnet_2_id" { 
  description = "The ID of the second subnet for the RDS database"
  type        = string
  
}


# Project name used for tagging database resources.
variable "project" {
  description = "The name of the project"
  type        = string
}

# Allocated storage size for RDS in gigabytes.
variable "allocated_storage" {
  description = "The allocated storage for the RDS database in gigabytes"
  type        = number
}
# Initial database name to create in RDS.
variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}
# Database engine name (for example mysql).
variable "engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}
# Database engine version for RDS.
variable "engine_version" {
  description = "The version of the database engine to use"
  type        = string
}
# Instance class for the RDS instance.
variable "instance_class" {
  description = "The instance class for the RDS database (e.g., db.t3.micro)"
  type        = string
}
# Master username for database authentication.
variable "username" {
  description = "The master username for the RDS database"
  type        = string
}
# Master password for database authentication.
variable "password" {
  description = "The master password for the RDS database"
  type        = string
}
# Security group ID attached to the RDS instance.
variable "db_sg_id" {
  description = "The ID of the security group for the RDS database"
  type        = string
}