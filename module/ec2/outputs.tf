output "instance" {
  value = aws_instance.ec2.id
}

output "host" {
  value = aws_instance.ec2.private_dns
}
