variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used when creating resources in AWS"
  type        = string
  default     = "event-ticket-platform"
}

variable "environment" {
  description = "Depyloyment environment"
  type        = string
  default     = "demo"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the FastAPI backend"
  type        = string
  default     = "t3.micro"
}