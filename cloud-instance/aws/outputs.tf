output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "ebs_volume_id" {
  description = "ID of the EBS data volume"
  value       = aws_ebs_volume.data_volume.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance_sg.id
}

output "ssm_connection_command" {
  description = "Command to connect to the instance via SSM"
  value       = "aws ssm start-session --target ${aws_instance.main.id} --region ${var.aws_region}"
}
