variable "region" {
  description = "AWS region."
  type        = string
}

variable "engine_version" {
  description = "Engine version of elasticsearch."
  type        = string
  default     = "OpenSearch_1.3"
}

variable "name" {
  description = "Name of OpenSerach domain and suffix of all other resources."
  type        = string
}


variable "master_user_name" {
  description = "Master username for accessing OpenSerach."
  type        = string
  default     = "admin"
}


variable "master_password" {
  description = "Master password for accessing OpenSearch. If not specified password will be randomly generated. Password will be stored in AWS `System Manager` -> `Parameter Store` "
  type        = string
  default     = ""
}

variable "master_user_arn" {
  description = "Master user ARN for accessing OpenSearch. If this is set, `advanced_security_options_enabled` must be set to true and  `internal_user_database_enabled` should be set to false."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "t3.small.search"
}

variable "domain_endpoint_options_enforce_https" {
  description = "Enforce https."
  type        = bool
  default     = true
}


variable "custom_endpoint_enabled" {
  description = "If custom endpoint is enabled."
  type        = bool
  default     = false
}

variable "custom_endpoint" {
  description = "Custom endpoint https."
  type        = string
  default     = ""
}

variable "custom_endpoint_certificate_arn" {
  description = "Custom endpoint certificate."
  type        = string
  default     = null
}

variable "volume_size" {
  description = "Volume size of ebs storage."
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Volume type of ebs storage."
  type        = string
  default     = "gp2"
}

variable "access_policy" {
  description = "Access policy to OpenSearch. If `default_policy_for_fine_grained_access_control` is enabled, this policy would be overwritten."
  type        = string
  default     = null
}

variable "tls_security_policy" {
  description = "TLS security policy."
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "vpc" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "CIDS blocks of subnets."
  type        = list(string)
  default     = []
}

variable "inside_vpc" {
  description = "Openserach inside VPC."
  type        = bool
  default     = false
}

variable "cognito_enabled" {
  description = "Cognito authentification enabled for OpenSearch."
  type        = bool
  default     = false
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "Allowed cidrs in security group."
  default     = []
}

variable "zone_id" {
  type        = string
  description = "Route 53 Zone id."
  default     = ""
}

variable "advanced_security_options_enabled" {
  type        = bool
  description = "If advanced security options is enabled."
  default     = false
}


variable "identity_pool_id" {
  type        = string
  description = "Cognito identity pool id."
  default     = ""
}

variable "user_pool_id" {
  type        = string
  description = "Cognito user pool id."
  default     = ""
}

variable "cognito_role_arn" {
  type        = string
  description = "Cognito role ARN. We need to enable `advanced_security_options_enabled`."
  default     = ""
}


variable "implicit_create_cognito" {
  type        = bool
  description = "Cognito will be created inside module. If this is not enables and we want cognito authentication, we need to create cognito resources outside of module."
  default     = true
}

variable "internal_user_database_enabled" {
  type        = bool
  description = "Internal user database enabled. This should be enabled if we want authentication with master username and master password."
  default     = false
}


variable "create_a_record" {
  type        = bool
  description = "Create A record for custom domain."
  default     = true
}

variable "ebs_enabled" {
  type        = bool
  description = "EBS enabled"
  default     = true
}

variable "aws_service_name_for_linked_role" {
  type        = string
  description = "AWS service name for linked role."
  default     = "opensearchservice.amazonaws.com"
}


variable "default_policy_for_fine_grained_access_control" {
  type        = bool
  description = "Default policy for fine grained access control would be created."
  default     = false
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options."
  type        = map(string)
  default     = {}
}

variable "iops" {
  description = "Baseline input/output (I/O) performance of EBS volumes attached to data nodes."
  type        = number
  default     = null
}

variable "throughput" {
  description = "Specifies the throughput."
  type        = number
  default     = null
}

variable "cluster_config" {
  description = "Auto tune options from documentation."
  type        = any
  default     = {}
}

variable "encrypt_at_rest" {
  description = "Encrypt at rest."
  type        = any
  default     = {}
}

variable "log_publishing_options" {
  description = "Encrypt at rest."
  type        = any
  default     = {}
}

variable "node_to_node_encryption" {
  type        = bool
  description = "Is node to node encryption enabled."
  default     = false
}

variable "tags" {
  description = "Tags."
  type        = map(any)
  default     = {}
}

variable "sg_ids" {
  type        = string
  description = "Use any pre-existing SGs."
  default     = ""
}

variable "create_linked_role" {
  type        = bool
  default     = true
  description = "Should linked role be created"
}

variable "default_security_group_name" {
  type        = string
  default     = ""
  description = "Default security group name"
}

variable "create_default_sg" {
  type        = bool
  default     = true
  description = "Creates default security group if value is true"
}

variable "custom_es_cognito_role_name" {
  type        = string
  default     = null
  description = "Custom name for Opensearch Cognito role name"
}


variable "allow_unauthenticated_identities" {
  type        = bool
  description = "Allow unauthenticated identities on Cognito Identity Pool"
  default     = true
}

variable "role_mapping" {
  type        = any
  description = "Custom role mapping for identity pool role attachment"
  default     = []
}

variable "mfa_configuration" {
  type        = string
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool"
  default     = "OFF"
}

variable "off_peak_window_enabled" {
  type        = bool
  description = "Enabled the off peak update 10 hour update window. All domains created after Feb 16 2023 will have the off_peak_window_options enabled by default."
  default     = true
}

variable "off_peak_window_start_time" {
  type        = object({
    hours = number
    minutes = number
  })

  description = "Time for the 10h update window to begin. If you don't specify a window start time, AWS will default it to 10:00 P.M. local time."
  default     = null
}
