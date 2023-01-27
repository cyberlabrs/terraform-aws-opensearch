data "aws_iam_policy_document" "cognito_es_policy" {
  count   = var.cognito_enabled ? 1 : 0
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DescribeUserPoolClient",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUserPoolClients",
      "cognito-identity:DescribeIdentityPool",
      "cognito-identity:UpdateIdentityPool",
      "cognito-identity:SetIdentityPoolRoles",
      "cognito-identity:GetIdentityPoolRoles"
    ]
    resources = [
      "*",
    ]
  }
}

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

resource "aws_iam_policy" "cognito_es_policy" {
  count  = var.cognito_enabled ? 1 : 0
  name   = "${var.name}-COGNITO-ACCESS-ES-POLICY"
  policy = data.aws_iam_policy_document.cognito_es_policy[0].json

}


resource "aws_iam_role" "cognito_es_role" {
  count              = var.cognito_enabled ? 1 : 0
  name               = "${var.name}-COGNITO-ACCESS-ES-ROLE"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy[0].json

}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  count      = var.cognito_enabled ? 1 : 0
  role       = aws_iam_role.cognito_es_role[0].name
  policy_arn = aws_iam_policy.cognito_es_policy[0].arn
}