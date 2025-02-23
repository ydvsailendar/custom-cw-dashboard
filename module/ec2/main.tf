resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.sg]
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true
  root_block_device {
    volume_size = 3
  }
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    log_group = var.log_group
  }))
  user_data_replace_on_change = false
}
