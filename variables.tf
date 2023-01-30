variable "region" {
  description = "AWS region"
  type        = string
}

variable "engine_version" {
  description = "Engine version of elasticsearch"
  type        = string
  default     = "OpenSearch_1.3"
}

variable "name" {
  description = "Resource name"
  type        = string
}


variable "master_user_name" {
  description = "Master username for accessing openserach"
  type        = string
  default     = "admin"
}


variable "master_password" {
  description = "Master password for accessing openserach"
  type        = string
  default     = ""
}

variable "master_user_arn" {
  description = "Master user ARN for accessing openserach"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.small.search"
}

variable "domain_endpoint_options_enforce_https" {
  description = "Enforce https"
  type        = bool
  default     = true
}


variable "custom_endpoint_enabled" {
  description = "Custom endpoint"
  type        = bool
  default     = false
}

variable "custom_endpoint" {
  description = "Custom endpoint https"
  type        = string
  default     = ""
}

variable "custom_endpoint_certificate_arn" {
  description = "Custom endpoint certificate"
  type        = string
  default     = null
}

variable "volume_size" {
  description = "Volume size of ebs storage"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Volume type of ebs storage"
  type        = string
  default     = "gp2"
}

variable "access_policy" {
  description = "Create generic access policy"
  type        = string
  default     = null
}

variable "tls_security_policy" {
  description = "TLS security policy"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "vpc" {
  description = "VPC name"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "CIDS blocks of private subnets"
  type        = list(string)
  default     = []
}

variable "inside_vpc" {
  description = "Openserach inside VPC"
  type        = bool
  default     = false
}

variable "cognito_enabled" {
  description = "Cognito authentification enabled for OpenSearch"
  type        = bool
  default     = false
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "Allowed cidrs in security group"
  default     = []
}

variable "zone_id" {
  type        = string
  description = "Route 53 Zone id"
  default     = ""
}

variable "advanced_security_options_enabled" {
  type        = bool
  description = "If advanced security options is enabled"
  default     = false
}


variable "identity_pool_id" {
  type        = string
  description = "Cognito identity pool id"
  default     = ""
}

variable "user_pool_id" {
  type        = string
  description = "User pool id"
  default     = ""
}

variable "cognito_role_arn" {
  type        = string
  description = "Cognito role arn"
  default     = ""
}


variable "implicit_create_cognito" {
  type        = bool
  description = "Cognito will be created inside module"
  default     = true
}

variable "internal_user_database_enabled" {
  type        = bool
  description = "Internal user database enabled"
  default     = false
}


variable "create_a_record" {
  type        = bool
  description = "Create A record for custom domain"
  default     = true
}

variable "ebs_enabled" {
  type        = bool
  description = "EBS enabled"
  default     = true
}

variable "aws_service_name_for_linked_role" {
  type        = string
  description = "AWS service name for linked role"
  default     = "opensearchservice.amazonaws.com"
}


variable "default_policy_for_fine_grained_access_control" {
  type        = bool
  description = "If domain access is open"
  default     = false
}