variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "preview-platform"
}

variable "instance_type" {
  description = "EC2 instance type for k3s node"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "AWS Key Pair name for SSH access to EC2"
  type        = string
  default     = "preview-platform-key"
}
