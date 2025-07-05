output "jumpbox_public_ip" {
  value = aws_instance.jumpbox.public_ip
}

output "jumpbox_security_group_id" {
  value = aws_security_group.jumpbox.id
}
