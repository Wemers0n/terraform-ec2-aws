output "instance_id" {
  description = "ID of the ec2 instance"
  value = aws_instance.app_server.id
}

output "instance_public_id" {
  description = "public IP address pf the ec2 instance"
  value = aws_instance.app_server.public_ip
}