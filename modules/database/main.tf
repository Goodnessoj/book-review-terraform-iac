# Managed RDS instance for the book review application.
resource "aws_db_instance" "book_review_db" {
  identifier       = "book-review-db"
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.4"
  skip_final_snapshot  = true
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.book_review_db_subnet_group.id
}

# Subnet group containing private database subnets for RDS.
resource "aws_db_subnet_group" "book_review_db_subnet_group" {
  name       = "book-review-db-subnet-group"
  subnet_ids = [var.db_subnet_1_id, var.db_subnet_2_id]
  tags = {
    Name = "${var.project}-db-subnet-group"
  }
  
}
