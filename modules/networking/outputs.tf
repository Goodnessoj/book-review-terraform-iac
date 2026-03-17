# VPC ID exported for downstream modules.
output "book_review_vpc_id" {
  value = aws_vpc.book-review-vpc.id
}

# ID of web subnet 1.
output "web_subnet_1_id" {
  value = aws_subnet.web_subnet_1.id
}

# ID of web subnet 2.
output "web_subnet_2_id" {
  value = aws_subnet.web_subnet_2.id
}

# ID of app subnet 1.
output "app_subnet_1_id" {
  value = aws_subnet.app_subnet_1.id
}

# ID of app subnet 2.
output "app_subnet_2_id" {
  value = aws_subnet.app_subnet_2.id
}

# ID of database subnet 1.
output "db_subnet_1_id" {
  value = aws_subnet.db_subnet_1.id
}

# ID of database subnet 2.
output "db_subnet_2_id" {
  value = aws_subnet.db_subnet_2.id
}

# Duplicate VPC ID output for compatibility.
output "vpc_id" {
  value = aws_vpc.book-review-vpc.id
}
