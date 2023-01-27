output "os_password" {
  value     = random_password.password.result
  sensitive = true
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
  value = try(aws_cognito_user_pool.user_pool[0].id, "")
}

output "identity_pool_id" {
  value = try(aws_cognito_identity_pool.identity_pool[0].id, "")
}

output "app_client_id" {
  value = try(aws_cognito_user_pool_client.client[0].id, "")
}