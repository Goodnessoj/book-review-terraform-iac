# Connection endpoint for the provisioned RDS instance.
output "db_endpoint" {
  value = aws_db_instance.book_review_db.endpoint
}