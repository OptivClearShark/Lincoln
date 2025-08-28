output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "splunk_instance_ids" {
  description = "Instance IDs of the Splunk servers"
  value       = aws_instance.splunk[*].id
}

output "splunk_instance_private_ips" {
  description = "Private IP addresses of the Splunk instances"
  value       = aws_instance.splunk[*].private_ip
}

output "ami_id" {
  description = "AMI ID used for the Splunk instance"
  value       = data.aws_ami.splunk_ami.id
}

output "ami_name" {
  description = "AMI name used for the Splunk instance"
  value       = data.aws_ami.splunk_ami.name
}

output "ssm_connect_commands" {
  description = "AWS CLI commands to connect via SSM for each instance"
  value       = [for id in aws_instance.splunk[*].id : "aws ssm start-session --target ${id} --region ${var.aws_region}"]
}

output "ssm_connect_command" {
  description = "AWS CLI command to connect to the first instance via SSM"
  value       = length(aws_instance.splunk) > 0 ? "aws ssm start-session --target ${aws_instance.splunk[0].id} --region ${var.aws_region}" : ""
}

output "security_group_ids" {
  description = "Security group IDs created"
  value = {
    splunk_instance = aws_security_group.splunk_instance.id
  }
}

output "iam_role_arn" {
  description = "ARN of the IAM role for SSM"
  value       = aws_iam_role.ssm_role.arn
}
