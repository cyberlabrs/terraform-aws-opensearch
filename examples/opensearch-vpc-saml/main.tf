


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


module "opensearch" {
  source                                         = "../../"
  name                                           = "vpc-os"
  region                                         = var.region
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  inside_vpc                                     = true
  vpc                                            = var.vpc_id
  subnet_ids                                     = [for subnet in data.aws_subnet.private : subnet.id]
  allowed_cidrs                                  = [data.aws_vpc.selected.cidr_block]
  node_to_node_encryption                        = true
  encrypt_at_rest = {
    enabled = true
  }
}