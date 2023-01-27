locals {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  count = var.inside_vpc ? 1 : 0
  id    = var.vpc
}

data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.key
}

resource "random_password" "password" {
  length      = 32
  special     = false
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "aws_security_group" "es" {
  count       = var.inside_vpc ? 1 : 0
  name        = "${var.vpc}-elasticsearch"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.selected[0].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = var.aws_service_name_for_linked_role
}

resource "aws_iam_service_linked_role" "es_shared" {
  count            = var.extra_aws_role_enabled ? 1 : 0
  provider         = aws.extra
  aws_service_name = var.aws_service_name_for_linked_role
}

resource "time_sleep" "role_dependency" {
  create_duration = "10s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    role_arn = try(aws_iam_role.cognito_es_role[0].arn, "arn:aws:iam::911111111111:role/mockup")
    linked_role_id = try(aws_iam_service_linked_role.es_shared[0].id, "11111")
  }
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.name
  engine_version = var.engine_version

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    internal_user_database_enabled = var.internal_user_database_enabled
    master_user_options {
      master_user_arn      = var.master_user_arn == "" ? try(aws_iam_role.authenticated[0].arn, null) : var.master_user_arn
      master_user_name     = var.internal_user_database_enabled ? var.master_user_name : ""
      master_user_password = var.internal_user_database_enabled ? random_password.password.result : ""
    }
  }

  dynamic "vpc_options" {
    for_each = var.inside_vpc == true ? toset([1]) : toset([0])
    content {
      subnet_ids         = [var.subnet_ids[0]]
      security_group_ids = [aws_security_group.es[0].id]
    }
  }

  dynamic "cognito_options" {
    for_each = var.cognito_enabled == true ? toset([1]) : toset([0])
    content {
      enabled          = var.cognito_enabled
      user_pool_id     = var.implicit_create_cognito == true ? try(aws_cognito_user_pool.user_pool[0].id, "user_pool") : var.user_pool_id
      identity_pool_id = var.identity_pool_id == "" && var.implicit_create_cognito == true ? try(aws_cognito_identity_pool.identity_pool[0].id, "identity_pool") : var.identity_pool_id
      role_arn         = var.implicit_create_cognito == true ? time_sleep.role_dependency.triggers["role_arn"] : var.cognito_role_arn
    }
  }

  cluster_config {
    instance_type = var.instance_type
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  node_to_node_encryption {
    enabled = true
  }

  access_policies = var.access_policy == "" ? (<<CONFIG
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "es:*",
                "Principal": "*",
                "Effect": "Allow",
                "Resource": ["arn:aws:es:${local.region}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*",
                            "arn:aws:es:${local.region}:${data.aws_caller_identity.current.account_id}:domain/${var.name}"]
            }
        ]
    }
    CONFIG 
  ) : var.access_policy

  domain_endpoint_options {
    enforce_https                   = var.domain_endpoint_options_enforce_https
    custom_endpoint_enabled         = var.custom_endpoint_enabled
    custom_endpoint                 = var.custom_endpoint_enabled ? var.custom_endpoint : null
    custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null
    tls_security_policy             = var.tls_security_policy
  }

  depends_on = [aws_iam_service_linked_role.es, aws_iam_service_linked_role.es_shared[0],time_sleep.role_dependency]
}


resource "aws_route53_record" "domain_record" {
  count      = var.custom_endpoint_enabled && var.create_a_record ? 1 : 0
  zone_id    = var.zone_id
  name       = var.custom_endpoint
  type       = "CNAME"
  ttl        = 60
  records    = [aws_opensearch_domain.opensearch.endpoint]
  depends_on = [aws_opensearch_domain.opensearch]
}