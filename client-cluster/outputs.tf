output "instance_public_ip" {
  value = aws_instance.consul_client.public_ip
}

output "instance_id" {
  value = aws_instance.consul_client.id
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_command" {
  value = "ssh -i client-cluster/hcp-key.pem ubuntu@${aws_instance.consul_client.public_ip}"
}
