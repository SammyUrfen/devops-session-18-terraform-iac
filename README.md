# Terraform & Infrastructure as Code Homework — Session 18
Bibek Jyoti Charah — 24bcs10112 (GitHub: SammyUrfen)

Environment: Fedora Linux, Terraform v1.16.1, AWS provider `hashicorp/aws` v6.67.0. No Kubernetes cluster
is needed for this session. The Terraform steps ran against a real AWS account (AWS CLI v2, region
`ap-south-1`). All output is pasted as printed, and long output is cut with `...`. The 12-digit AWS
account ID is replaced with `<ACCOUNT_ID>`.

## Status

| Step | Result |
|---|---|
| `terraform version` | v1.16.1 |
| `terraform init` | aws provider v6.67.0 installed |
| `terraform fmt` | No changes needed |
| `terraform validate` | `Success! The configuration is valid.` |
| `terraform plan` | 4 to add |
| `terraform apply` | 4 added, and `aws s3 ls` shows the bucket |
| `terraform show` | Bucket, versioning, public access block, SSE in state |
| `terraform output` | `bucket_name`, `bucket_arn`, `bucket_region` |
| `terraform destroy` | 4 destroyed, and `aws s3 ls` and `terraform state list` show nothing |
| AWS services research (5 READMEs) | Done — examples are written, not run |

## Task 1 — Terraform S3 demo

[`terraform-s3-demo/`](terraform-s3-demo/) — one private S3 bucket in `ap-south-1` with a unique name
(`bucket_prefix`), versioning, a public access block, and default AES256 encryption. The README has the
full workflow with the real output from `init` to `destroy`.

## Task 2 — AWS services

| # | Service | Area |
|---|---|---|
| 01 | [IAM](aws-services/01-iam/README.md) | Governance |
| 02 | [EC2](aws-services/02-ec2/README.md) | Compute |
| 03 | [S3](aws-services/03-s3/README.md) | Storage |
| 04 | [VPC](aws-services/04-vpc/README.md) | Networking |
| 05 | [DynamoDB & RDS](aws-services/05-dynamodb-rds/README.md) | Databases |

## Findings

- The course demo uses a fixed bucket name. S3 names are global, so a fixed name fails if anyone else
  owns it. This repo uses `bucket_prefix`, and AWS adds a unique suffix.
- The course demo puts the `terraform {}` block in a separate `terraform.tf`. The homework asks for one
  `provider.tf`, so this repo keeps the `terraform {}` and `provider` blocks together there.
- The first `apply` failed. The IAM user had no S3 permissions:
  ```
  $ terraform apply s18.tfplan
  aws_s3_bucket.demo: Creating...

  Error: creating S3 Bucket (bibek-s18-demo-1796a2cf0c332dd663eb469a30): operation error S3: CreateBucket, https response error StatusCode: 403, ... api error AccessDenied: User: arn:aws:iam::<ACCOUNT_ID>:user/SammyUrfen-CLI is not authorized to perform: s3:CreateBucket on resource: "arn:aws:s3:::bibek-s18-demo-1796a2cf0c332dd663eb469a30" because no identity-based policy allows the s3:CreateBucket action
  ```
  Nothing was created. The fix: attach `AmazonS3FullAccess` to the user, then run `plan` and `apply`
  again. The second run is the one in `terraform-s3-demo/README.md`.
- In `terraform show`, the bucket's own `versioning` block says `enabled = false`, but the
  `aws_s3_bucket_versioning` resource says `Enabled`. The bucket value is stale. Terraform read the bucket
  before versioning was turned on.
