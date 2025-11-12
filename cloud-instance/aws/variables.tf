variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "availability_zone" {
  description = "Availability zone for the EBS volume and instance"
  type        = string
  default     = "us-east-2a"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "cloud-works"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 30
}
