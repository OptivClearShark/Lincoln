variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.aws_region))
    error_message = "aws_region must look like 'us-east-1'."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "lincoln"
  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must be a non-empty string."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "splunk_version" {
  description = "Splunk version to match with Packer AMI"
  type        = string
  default     = "9.4.4"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR (e.g., 10.0.0.0/16)."
  }
}

variable "sh_instance_type" {
  description = "EC2 instance type for Splunk server"
  type        = string
  default     = "t3.large"
  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.sh_instance_type))
    error_message = "instance_type must look like 't3.large'."
  }
}

variable "idx_instance_type" {
  description = "EC2 instance type for Splunk server"
  type        = string
  default     = "t3.large"
  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.idx_instance_type))
    error_message = "instance_type must look like 't3.large'."
  }
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 128
  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be at least 8 GB."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring on the EC2 instance"
  type        = bool
  default     = false
}

variable "require_imds_v2" {
  description = "Require IMDSv2 for instance metadata"
  type        = bool
  default     = true
}

variable "t_instance_unlimited" {
  description = "Use unlimited CPU credits on T-family instances"
  type        = bool
  default     = false
}

variable "enable_t_instance_credit_spec" {
  description = "Include credit_specification (set true for T-family instances)"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Protect the EC2 instance from API termination"
  type        = bool
  default     = false
}

## DNS for NLB (Route 53)
variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for your domain (can include '/hostedzone/' prefix). Leave empty to skip record creation."
  type        = string
  default     = "/hostedzone/Z049435030NGGQM3AI8IC"
}

variable "domain" {
  type    = string
  default = "clearsharkworks.com"
}

variable "interviewer" {
  description = "First and last name of O+CS interviewer"
  type        = string
}

variable "interviewee_fn" {
  description = "First name of interviewee"
  type        = string
}

variable "interviewee_ln" {
  description = "Last name of interviewee"
  type        = string
}

variable "ssh_pw" {
  description = "Password for interviewee's account"
  type        = string
  sensitive   = true
}