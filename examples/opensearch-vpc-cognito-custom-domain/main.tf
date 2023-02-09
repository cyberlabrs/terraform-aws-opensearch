


data "aws_vpc" "selected" {
  id = var.vpc_id
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["**private**"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "opensearch" {
  source                            = "../../"
  name                              = var.vpc_id
  region                            = var.region
  advanced_security_options_enabled = true
  custom_endpoint                   = var.custom_domain
  custom_endpoint_enabled           = true
  custom_endpoint_certificate_arn   = aws_acm_certificate.cert.arn
  zone_id                           = var.zone_id
  cognito_enabled                   = true
  node_to_node_encryption           = true
  encrypt_at_rest = {
    enabled = true
  }
}