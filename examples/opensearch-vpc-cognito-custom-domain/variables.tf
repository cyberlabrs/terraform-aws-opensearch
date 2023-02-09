variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = "vpc-xxxxx"
}


variable "zone_id" {
  type        = string
  description = "Route53 zone id"
  default     = "xxxxxxxxxxxxxxxx"
}

variable "custom_domain" {
  type        = string
  description = "Custom domain value"
  default     = "xxxxxxxxxxxxxxxx"
}


variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}