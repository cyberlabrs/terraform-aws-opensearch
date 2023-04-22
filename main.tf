locals {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  count = var.inside_vpc ? 1 : 0
  id    = var.vpc
}

resource "random_password" "password" {
  count       = var.internal_user_database_enabled ? 1 : 0
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

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = var.aws_service_name_for_linked_role
}

resource "time_sleep" "role_dependency" {
  create_duration = "20s"

  triggers = {
    role_arn       = try(aws_iam_role.cognito_es_role[0].arn, null),
    linked_role_id = try(aws_iam_service_linked_role.es.id, "11111")
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
      master_user_password = var.internal_user_database_enabled ? coalesce(var.master_password, random_password.password[0].result) : ""
    }
  }

  advanced_options = var.advanced_options

  dynamic "vpc_options" {
    for_each = var.inside_vpc ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.es[0].id]
    }
  }

  dynamic "cognito_options" {
    for_each = var.cognito_enabled ? [1] : []
    content {
      enabled          = var.cognito_enabled
      user_pool_id     = var.implicit_create_cognito == true ? aws_cognito_user_pool.user_pool[0].id : var.user_pool_id
      identity_pool_id = var.identity_pool_id == "" && var.implicit_create_cognito == true ? aws_cognito_identity_pool.identity_pool[0].id : var.identity_pool_id
      role_arn         = var.implicit_create_cognito == true ? time_sleep.role_dependency.triggers["role_arn"] : var.cognito_role_arn
    }
  }

  cluster_config {
    instance_type            = var.instance_type
    dedicated_master_enabled = try(var.cluster_config["dedicated_master_enabled"], false)
    dedicated_master_count   = try(var.cluster_config["dedicated_master_count"], 0)
    dedicated_master_type    = try(var.cluster_config["dedicated_master_type"], "t2.small.elasticsearch")
    instance_count           = try(var.cluster_config["instance_count"], 1)
    warm_enabled             = try(var.cluster_config["warm_enabled"], false)
    warm_count               = try(var.cluster_config["warm_enabled"], false) ? try(var.cluster_config["warm_count"], null) : null
    warm_type                = try(var.cluster_config["warm_type"], false) ? try(var.cluster_config["warm_type"], null) : null
    zone_awareness_enabled   = try(var.cluster_config["zone_awareness_enabled"], false)
    dynamic "zone_awareness_config" {
      for_each = try(var.cluster_config["avability_zone_count"], 1) > 1 && try(var.cluster_config["zone_awareness_enabled"], false) ? [1] : []
      content {
        availability_zone_count = try(var.cluster_config["avability_zone_count"], 1)
      }
    }
  }

  encrypt_at_rest {
    enabled    = try(var.encrypt_at_rest["enabled"], false)
    kms_key_id = try(var.encrypt_at_rest["kms_key_id"], "")
  }

  dynamic "log_publishing_options" {
    for_each = try(var.log_publishing_options["audit_logs_enabled"], false) ? [1] : []
    content {
      enabled                  = try(var.log_publishing_options["audit_logs_enabled"], false)
      log_type                 = "AUDIT_LOGS"
      cloudwatch_log_group_arn = try(var.log_publishing_options["audit_logs_cw_log_group_arn"], null)
    }
  }

  dynamic "log_publishing_options" {
    for_each = try(var.log_publishing_options["application_logs_enabled"], false) ? [1] : []
    content {
      enabled                  = try(var.log_publishing_options["application_logs_enabled"], false)
      log_type                 = "ES_APPLICATION_LOGS"
      cloudwatch_log_group_arn = try(var.log_publishing_options["application_logs_cw_log_group_arn"], null)
    }
  }

  dynamic "log_publishing_options" {
    for_each = try(var.log_publishing_options["index_logs_enabled"], false) ? [1] : []
    content {
      enabled                  = try(var.log_publishing_options["index_logs_enabled"], false)
      log_type                 = "INDEX_SLOW_LOGS"
      cloudwatch_log_group_arn = try(var.log_publishing_options["index_logs_cw_log_group_arn"], null)
    }
  }

  dynamic "log_publishing_options" {
    for_each = try(var.log_publishing_options["search_logs_enabled"], false) ? [1] : []
    content {
      enabled                  = try(var.log_publishing_options["search_logs_enabled"], false)
      log_type                 = "SEARCH_SLOW_LOGS"
      cloudwatch_log_group_arn = try(var.log_publishing_options["search_logs_cw_log_group_arn"], null)
    }
  }


  ebs_options {
    ebs_enabled = var.ebs_enabled
    iops        = var.iops
    throughput  = var.throughput
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

  access_policies = var.access_policy == null && var.default_policy_for_fine_grained_access_control ? (<<CONFIG
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "es:*",
                "Principal": {
                  "AWS": "*"
                  },
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
  tags       = var.tags
  depends_on = [aws_iam_service_linked_role.es, time_sleep.role_dependency]
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
