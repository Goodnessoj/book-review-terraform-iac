variable "book_review_vpc_id" {
  description = "book review vpc id"
  type = string

}
variable "project" {
  description = "The name of the project"
  type        = string
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  
}