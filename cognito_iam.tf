resource "aws_cognito_user_pool" "user_pool" {
  count = var.cognito_enabled ? 1 : 0
  name  = "cognito-${var.name}"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"
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
    temporary_password_validity_days = 90
  }
}

resource "aws_cognito_user_pool_client" "client" {
  count = var.cognito_enabled ? 1 : 0
  name  = "user_client_${var.name}"

  user_pool_id        = aws_cognito_user_pool.user_pool[0].id
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count        = var.cognito_enabled ? 1 : 0
  domain       = "opensearch-fornulio-auth"
  user_pool_id = aws_cognito_user_pool.user_pool[0].id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  count                            = var.cognito_enabled ? 1 : 0
  identity_pool_name               = "${var.name}_identity_pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id     =  aws_cognito_user_pool_client.client[0].id
    provider_name = aws_cognito_user_pool.user_pool[0].endpoint
  }

  lifecycle {ignore_changes = [cognito_identity_providers]}
}




//authenticated role
resource "aws_iam_role" "authenticated" {
  count = var.cognito_enabled ? 1 : 0
  name  = format("cognito_authenticated-%s", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool[0].id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  count = var.cognito_enabled ? 1 : 0
  name  = format("authenticated_policy-%s", var.name)
  role  = aws_iam_role.authenticated[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

//unauthenticated role
resource "aws_iam_role" "unauthenticated" {
  count = var.cognito_enabled ? 1 : 0
  name  = format("cognito_unauthenticated-%s", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool[0].id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "unauthenticated" {
  count = var.cognito_enabled ? 1 : 0
  name  = format("unauthenticated_policy-%s", var.name)
  role  = aws_iam_role.unauthenticated[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}


resource "aws_cognito_identity_pool_roles_attachment" "roles_attachment" {
  count            = var.cognito_enabled ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.identity_pool[0].id

  roles = {
    "authenticated"   = aws_iam_role.authenticated[0].arn,
    "unauthenticated" = aws_iam_role.unauthenticated[0].arn,
  }
}