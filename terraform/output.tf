output "ssh_private_key" {
  value = tls_private_key.main.private_key_pem
}

output "instance_public_dns" {
  value = aws_instance.public.*.public_dns
}
