# user pool
resource "aws_cognito_user_pool" "user_pool" {
  count = var.cognito_enabled ? 1 : 0
  name  = "${var.name}_user_pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]
  mfa_configuration        = var.mfa_configuration
  username_attributes      = ["email"]

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration == "ON" ? [1] : []
    content {
      enabled = true
    }
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count        = var.cognito_enabled ? 1 : 0
  domain       = var.name
  user_pool_id = aws_cognito_user_pool.user_pool[0].id
}

# identity pool
resource "aws_cognito_identity_pool" "identity_pool" {
  count                            = var.cognito_enabled ? 1 : 0
  identity_pool_name               = "${var.name}_identity_pool"
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  # AWS OpenSearch will maintain `cognito_identity_providers`, so ignore it
  lifecycle { ignore_changes = [cognito_identity_providers] }
}
