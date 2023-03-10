output "os_password" {
  value       = random_password.password.result
  description = "Master user password for OpenSearch"
  sensitive   = true
}


output "cognito_map" {
  description = "cognito info"
  value = { "user_pool" = try(aws_cognito_user_pool.user_pool[0].id, "")
    "identity_pool" = try(aws_cognito_identity_pool.identity_pool[0].id, "")
    "auth_arn"      = try(aws_iam_role.authenticated[0].arn, "")
    "domain"        = try("${aws_cognito_user_pool_domain.user_pool_domain[0].domain}.auth.${var.region}.amazoncognito.com", "")
  }
}

output "user_pool_id" {
  description = "Cognito user pool ID"
  value       = try(aws_cognito_user_pool.user_pool[0].id, "")
}

output "identity_pool_id" {
  description = "Cognito identity pool ID"
  value       = try(aws_cognito_identity_pool.identity_pool[0].id, "")
}

output "app_client_id" {
  description = "Cognito user pool app client  ID"
  value       = try(aws_cognito_user_pool_client.client[0].id, "")
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

output "kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme"
  value       = aws_opensearch_domain.opensearch.kibana_endpoint
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_opensearch_domain.opensearch.tags_all
}

output "availability_zones" {
  description = "If the domain was created inside a VPC, the names of the availability zones the configured subnet_ids were created inside"
  value       = aws_opensearch_domain.opensearch.vpc_options.0.availability_zones
}

output "vpc_id" {
  description = "If the domain was created inside a VPC, the ID of the VPC"
  value       = aws_opensearch_domain.opensearch.vpc_options.0.vpc_id
}