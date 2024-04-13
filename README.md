# kartaca-bulut-muhendisi-task
Creating Google Cloud Platform (GCP) resources with Terraform

[![publish to dev.to](https://github.com/akinbezatoglu/kartaca-bulut-muhendisi-task/actions/workflows/terraform.yaml/badge.svg)](https://github.com/akinbezatoglu/kartaca-bulut-muhendisi-task/actions/workflows/terraform.yaml)

---

![terraform.svg](https://github.com/akinbezatoglu/kartaca-bulut-muhendisi-task/assets/61403011/b6a4051b-342d-4e9b-9fdf-da35e5881cdc)

---

### Software Dependencies
#### Terraform and Plugins
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.7.5
- [Terraform Provider for GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs) v5.0+

### Enable APIs
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - compute.googleapis.com
- Kubernetes Engine API - container.googleapis.com
- Cloud SQL Admin API - sqladmin.googleapis.com
- Cloud Deployment Manager V2 API - deploymentmanager.googleapis.com
- Serverless VPC Access API - vpcaccess.googleapis.com
- Service Networking API - servicenetworking.googleapis.com
- Cloud Run Admin API - run.googleapis.com
- Cloud Resource Manager API - cloudresourcemanager.googleapis.com
- Secret Manager API - secretmanager.googleapis.com
- Identity and Access Management (IAM) API - iam.googleapis.com
