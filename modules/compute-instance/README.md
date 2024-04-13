
# Compute Instance Module
This module is a submodule that can be used as a building blocks to provision VMs in GCP.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_name | The name of the instance | `string` | `n/a` | yes |
| machine\_type | The type of the machine | `string` | `n/a` | yes |
| tags | The tags for the instance | `set(string)` | `null` | no |
| boot\_disk | The boot disk configuration |<pre>object({<br>image=optional(string), <br>size_gb=optional(number), <br>type=optional(string), <br>labels=optional(map(string))<br>})</pre> | `n/a` | yes |
| additional\_disks | The additional disks configuration	| <pre>list(object({<br>name=string, <br>type=optional(string), <br>size=optional(number), <br>zone=optional(string)<br>}))</pre> | `null` | no |
| network\_interfaces | The network interfaces configuration | <pre>list(object({<br>network=string, <br>subnetwork=string, <br>network_ip=string<br>}))</pre> | `null` | no |
| policy\_name | The name of the policy | `string` | `null` | no |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| name | The name of the Google Compute instance | `string` |
| private\_ip\_address | The private IP address(es) of the Google Compute instance’s network interface | `list` |

### Software Dependencies
#### Terraform and Plugins
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.7.5
- [Terraform Provider for GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs) v5.0+

### Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - compute.googleapis.com
- Identity and Access Management (IAM) API - iam.googleapis.com