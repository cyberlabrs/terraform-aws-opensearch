output "os_user_name" {
  value       = var.internal_user_database_enabled ? var.master_user_name : null
  description = "Master username for OpenSearch"
  sensitive   = true
}

output "os_password" {
  value       = try(random_password.password[0].result, null)
  description = "Master user password for OpenSearch"
  sensitive   = true
}


output "cognito_map" {
  description = "cognito info"
  value = var.cognito_enabled ? { "user_pool" = try(aws_cognito_user_pool.user_pool[0].id, null)
    "identity_pool" = try(aws_cognito_identity_pool.identity_pool[0].id, null)
    "auth_arn"      = try(aws_iam_role.authenticated[0].arn, null)
    "domain"        = try("${aws_cognito_user_pool_domain.user_pool_domain[0].domain}.auth.${var.region}.amazoncognito.com", null)
  } : null
}

output "user_pool_id" {
  description = "Cognito user pool ID"
  value       = try(aws_cognito_user_pool.user_pool[0].id, null)
}

output "identity_pool_id" {
  description = "Cognito identity pool ID"
  value       = try(aws_cognito_identity_pool.identity_pool[0].id, null)
}

output "arn" {
  description = "ARN of the domain"
  value       = aws_opensearch_domain.opensearch.arn
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = aws_opensearch_domain.opensearch.domain_id
}

output "domain_name" {
  description = "Name of the Elasticsearch domain"
  value       = aws_opensearch_domain.opensearch.domain_name
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_opensearch_domain.opensearch.endpoint
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for Dashboard without https scheme"
  value       = aws_opensearch_domain.opensearch.dashboard_endpoint
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_opensearch_domain.opensearch.tags_all
}

output "availability_zones" {
  description = "If the domain was created inside a VPC, the names of the availability zones the configured subnet_ids were created inside"
  value       = try(aws_opensearch_domain.opensearch.vpc_options[0].availability_zones, null)
}

output "vpc_id" {
  description = "If the domain was created inside a VPC, the ID of the VPC"
  value       = try(aws_opensearch_domain.opensearch.vpc_options[0].vpc_id, null)
}
