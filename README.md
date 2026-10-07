# Terraform & Infrastructure as Code Homework — Session 18
Bibek Jyoti Charah — 24bcs10112 (GitHub: SammyUrfen)

Environment: Fedora Linux, Terraform v1.16.1, AWS provider `hashicorp/aws` v6.67.0. No Kubernetes cluster
is needed for this session. This machine has no AWS CLI and no AWS credentials yet, so only the steps
that do not call AWS ran. All output is pasted as printed, and long output is cut with `...`.

## Status

| Step | Status |
|---|---|
| `terraform version` | Ran — output pasted |
| `terraform init` | Ran — output pasted |
| `terraform fmt` | Ran — no changes needed |
| `terraform validate` | Ran — `Success! The configuration is valid.` |
| `terraform plan` | **Pending AWS credentials** |
| `terraform apply` | **Pending AWS credentials** |
| `terraform show` | **Pending AWS credentials** |
| `terraform output` | **Pending AWS credentials** |
| `terraform destroy` | **Pending AWS credentials** |
| AWS services research (5 READMEs) | Done — examples are written, not run |

No plan/apply output is shown anywhere in this repo. Those sections are placeholders until the commands
run against a real account.

## Task 1 — Terraform S3 demo

[`terraform-s3-demo/`](terraform-s3-demo/) — one private S3 bucket in `ap-south-1` with a unique name
(`bucket_prefix`), versioning, a public access block, and default AES256 encryption. The README has the
full workflow, the real output, and the steps to run once AWS is ready.

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
