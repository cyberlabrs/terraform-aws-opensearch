


data "aws_vpc" "selected" {
  id = "vpc-xxxxx"
}


module "opensearch" {
  source                                         = "cyberlabrs/opensearch/aws"
  version                                        = "0.0.7"
  name                                           = "vpc-os"
  region                                         = "eu-central-1"
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  inside_vpc                                     = true
  vpc                                            = "vpc-xxxxxxxx"
  subnet_ids                                     = ["subnet-1xxx", "subnet-2xxx"]
  allowed_cidrs                                  = [data.aws_vpc.selected.cidr_block]
  node_to_node_encryption                        = true
  encrypt_at_rest = {
    enabled = true
  }
}