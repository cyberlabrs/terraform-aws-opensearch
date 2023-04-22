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
  name               = "${var.name}_AmazonOpenSearchServiceCognitoAccess"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy[0].json
}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  count      = var.cognito_enabled ? 1 : 0
  role       = aws_iam_role.cognito_es_role[0].name
  policy_arn = data.aws_iam_policy.cognito_es_policy[0].arn
}