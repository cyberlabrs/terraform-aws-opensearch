# es access cognito
data "aws_iam_policy_document" "es_assume_policy" {
  count   = var.cognito_enabled ? 1 : 0
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "cognito_es_policy" {
  count = var.cognito_enabled ? 1 : 0
  name  = "AmazonOpenSearchServiceCognitoAccess"
}


resource "aws_iam_role" "cognito_es_role" {
  count              = var.cognito_enabled ? 1 : 0
  name               = var.custom_es_cognito_role_name == null ? "${var.name}_AmazonOpenSearchServiceCognitoAccess" : var.custom_es_cognito_role_name
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy[0].json
}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  count      = var.cognito_enabled ? 1 : 0
  role       = aws_iam_role.cognito_es_role[0].name
  policy_arn = data.aws_iam_policy.cognito_es_policy[0].arn
}


# authenticated role
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

# unauthenticated role
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

  dynamic "role_mapping" {
    for_each = var.role_mapping
    content {
      ambiguous_role_resolution = try(role_mapping.value["ambiguous_role_resolution"], null)
      identity_provider         = try(role_mapping.value["identity_provider"], null)
      type                      = try(role_mapping.value["type"], null)
    }
  }
}
