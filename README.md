# AWS OpenSearch Terraform Module

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.52.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.3 |

## Usage

OpenSearch with basic setup with domain level access policy

```terraform
module "opensearch" {
  source  = "cyberlabrs/opensearch/aws"
  name    = "basic-os"
  region  = "eu-central-1"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["arn:aws:iam::acc-number:role/xxx"]
        },
        "Action" : "es:*",
        "Resource" : "arn:aws:es:region:acc-number:domain/domain-name/*"
      }
    ]
  })

}
```

OpenSearch with basic setup with fine grained access control with default policy with internal_user enabled

```terraform
module "opensearch" {
  source                                         = "cyberlabrs/opensearch/aws"
  name                                           = "basic-os"
  region                                         = "eu-central-1"
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  node_to_node_encryption                        = true
  encrypt_at_rest = {
    enabled = true
  }
}
```

OpenSearch with basic setup with fine grained access control with default policy with internal_user enabled inside VPC

```terraform
module "opensearch" {
  source                                         = "cyberlabrs/opensearch/aws"
  name                                           = "vpc-os"
  region                                         = "eu-central-1"
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  inside_vpc                                     = true
  vpc                                            = "vpc-xxxxxxxx"
  subnet_ids                                     = ["subnet-1xxx", "subnet-2xxx"]
  allowed_cidrs                                  = ["xxxxxx"]
  node_to_node_encryption                        = true
  encrypt_at_rest = {
    enabled = true
  }
}
```


OpenSearch with basic setup with fine grained access control with Cognito authentication and custom domain

```terraform
module "opensearch" {
  source                            = "cyberlabrs/opensearch/aws"
  version                           = "0.0.7"
  name                              = "vpc-os"
  region                            = "eu-central-1"
  advanced_security_options_enabled = true
  custom_endpoint                   = "xxxxxx"
  custom_endpoint_enabled           = true
  custom_endpoint_certificate_arn   = "xxxx"
  zone_id                           = "zone_id"
  cognito_enabled                   = true
  node_to_node_encryption           = true
  encrypt_at_rest = {
    enabled = true
  }
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_identity_pool.identity_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.roles_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_cognito_user_pool.user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.user_pool_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_iam_policy.cognito_es_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cognito_es_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.unauthenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.unauthenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cognito_es_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.es](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_opensearch_domain.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_route53_record.domain_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.es](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cognito_es_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.es_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Access policy to OpenSearch. If `default_policy_for_fine_grained_access_control` is enabled, this policy would be overwritten. | `string` | `null` | no |
| <a name="input_advanced_options"></a> [advanced\_options](#input\_advanced\_options) | Key-value string pairs to specify advanced configuration options | `map(string)` | `{}` | no |
| <a name="input_advanced_security_options_enabled"></a> [advanced\_security\_options\_enabled](#input\_advanced\_security\_options\_enabled) | If advanced security options is enabled. | `bool` | `false` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Allowed cidrs in security group. | `list(string)` | `[]` | no |
| <a name="input_aws_service_name_for_linked_role"></a> [aws\_service\_name\_for\_linked\_role](#input\_aws\_service\_name\_for\_linked\_role) | AWS service name for linked role. | `string` | `"opensearchservice.amazonaws.com"` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Auto tune options from documentation | `any` | `{}` | no |
| <a name="input_cognito_enabled"></a> [cognito\_enabled](#input\_cognito\_enabled) | Cognito authentification enabled for OpenSearch. | `bool` | `false` | no |
| <a name="input_cognito_role_arn"></a> [cognito\_role\_arn](#input\_cognito\_role\_arn) | Cognito role ARN. We need to enable `advanced_security_options_enabled`. | `string` | `""` | no |
| <a name="input_create_a_record"></a> [create\_a\_record](#input\_create\_a\_record) | Create A record for custom domain. | `bool` | `true` | no |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | Custom endpoint https. | `string` | `""` | no |
| <a name="input_custom_endpoint_certificate_arn"></a> [custom\_endpoint\_certificate\_arn](#input\_custom\_endpoint\_certificate\_arn) | Custom endpoint certificate. | `string` | `null` | no |
| <a name="input_custom_endpoint_enabled"></a> [custom\_endpoint\_enabled](#input\_custom\_endpoint\_enabled) | If custom endpoint is enabled. | `bool` | `false` | no |
| <a name="input_default_policy_for_fine_grained_access_control"></a> [default\_policy\_for\_fine\_grained\_access\_control](#input\_default\_policy\_for\_fine\_grained\_access\_control) | Default policy for fine grained access control would be created. | `bool` | `false` | no |
| <a name="input_domain_endpoint_options_enforce_https"></a> [domain\_endpoint\_options\_enforce\_https](#input\_domain\_endpoint\_options\_enforce\_https) | Enforce https. | `bool` | `true` | no |
| <a name="input_ebs_enabled"></a> [ebs\_enabled](#input\_ebs\_enabled) | EBS enabled | `bool` | `true` | no |
| <a name="input_encrypt_at_rest"></a> [encrypt\_at\_rest](#input\_encrypt\_at\_rest) | Encrypt at rest | `any` | `{}` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version of elasticsearch. | `string` | `"OpenSearch_1.3"` | no |
| <a name="input_identity_pool_id"></a> [identity\_pool\_id](#input\_identity\_pool\_id) | Cognito identity pool id. | `string` | `""` | no |
| <a name="input_implicit_create_cognito"></a> [implicit\_create\_cognito](#input\_implicit\_create\_cognito) | Cognito will be created inside module. It this is not enables and we want cognito authentication, we need to create cognito resources outside of module. | `bool` | `true` | no |
| <a name="input_inside_vpc"></a> [inside\_vpc](#input\_inside\_vpc) | Openserach inside VPC. | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type. | `string` | `"t3.small.search"` | no |
| <a name="input_internal_user_database_enabled"></a> [internal\_user\_database\_enabled](#input\_internal\_user\_database\_enabled) | Internal user database enabled. This should be enabled if we want authentication with master username and master password. | `bool` | `false` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | Baseline input/output (I/O) performance of EBS volumes attached to data nodes | `number` | `null` | no |
| <a name="input_log_publishing_options"></a> [log\_publishing\_options](#input\_log\_publishing\_options) | Encrypt at rest | `any` | `{}` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Master password for accessing OpenSearch. If not specified password will be randomly generated. | `string` | `""` | no |
| <a name="input_master_user_arn"></a> [master\_user\_arn](#input\_master\_user\_arn) | Master user ARN for accessing OpenSearch. If this is set, `advanced_security_options_enabled` must be set to true and  `internal_user_database_enabled` should be set to false. | `string` | `""` | no |
| <a name="input_master_user_name"></a> [master\_user\_name](#input\_master\_user\_name) | Master username for accessing OpenSerach. | `string` | `"admin"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of OpenSerach domain and sufix of all other resources. | `string` | n/a | yes |
| <a name="input_node_to_node_encryption"></a> [node\_to\_node\_encryption](#input\_node\_to\_node\_encryption) | Is node to node encryption enabled | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | CIDS blocks of subnets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(any)` | `{}` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Specifies the throughput | `number` | `null` | no |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | TLS security policy. | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| <a name="input_user_pool_id"></a> [user\_pool\_id](#input\_user\_pool\_id) | Cognito user pool id. | `string` | `""` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Volume size of ebs storage. | `number` | `10` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Volume type of ebs storage. | `string` | `"gp2"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC ID | `string` | `""` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route 53 Zone id. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the domain |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | If the domain was created inside a VPC, the names of the availability zones the configured subnet\_ids were created inside |
| <a name="output_cognito_map"></a> [cognito\_map](#output\_cognito\_map) | cognito info |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Unique identifier for the domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the Elasticsearch domain |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_identity_pool_id"></a> [identity\_pool\_id](#output\_identity\_pool\_id) | Cognito identity pool ID |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | Domain-specific endpoint for kibana without https scheme |
| <a name="output_os_password"></a> [os\_password](#output\_os\_password) | Master user password for OpenSearch |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito user pool ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | If the domain was created inside a VPC, the ID of the VPC |
