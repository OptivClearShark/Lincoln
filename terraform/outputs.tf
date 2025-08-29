output "ssm_connect_commands" {
  description = "AWS CLI commands to connect via SSM for each instance"
  value       = "aws ssm start-session --target ${aws_instance.searchhead.id} --region ${var.aws_region}"
}

output "ssm_connect_command" {
  description = "AWS CLI command to connect to the first instance via SSM"
  value       = length(aws_instance.searchhead) > 0 ? "aws ssm start-session --target ${aws_instance.searchhead.id} --region ${var.aws_region}" : ""
}

output "ssh_via_nlb_example" {
  description = "Example SSH command via the NLB DNS name"
  value       = "ssh -p 22 ec2-user@${aws_lb.splunk_nlb.dns_name}"
}

output "splunk_web_url" {
  description = "Splunk Web URL via the NLB DNS name"
  value       = "https://${aws_lb.splunk_nlb.dns_name}:8000"
}

output "ssh_fqdn" {
  description = "Route 53 SSH record name (if created)"
  value       = "${local.interviewee_initials}-ssh.${var.domain}"
}

output "splunk_fqdn" {
  description = "Route 53 Splunk record name (if created)"
  value       = "${local.interviewee_initials}-sh.${var.domain}"
}
