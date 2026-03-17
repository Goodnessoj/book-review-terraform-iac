# Public IP address of the web server instance.
output "web_server_pub_ip" {
  value = aws_instance.web_server.public_ip
}

# Private IP address of the app server instance.
output "app_server_prvt_ip" {
  value = aws_instance.app_server.private_ip
}

# EC2 instance ID for the web server.
output "web_server_instance_id" {
  value = aws_instance.web_server.id
}

# EC2 instance ID for the app server.
output "app_server_instance_id" {
  value = aws_instance.app_server.id
}
