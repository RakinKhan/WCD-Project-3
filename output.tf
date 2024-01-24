output "ec2_public_ip" {
  value       = aws_instance.project_3_instance.public_ip
  description = "Public IP of Project 3 Instance"
}