output "instance_public_ip" {
  description = "Public IP of the k3s EC2 instance"
  value       = aws_eip.k3s.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.k3s.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_eip.k3s.public_ip}"
}