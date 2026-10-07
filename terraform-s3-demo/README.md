# terraform-s3-demo

Creates one private S3 bucket in `ap-south-1` with Terraform.

| File | Purpose |
|---|---|
| `provider.tf` | Terraform version, AWS provider (`hashicorp/aws ~> 6.0`), region |
| `variables.tf` | `aws_region`, `bucket_prefix`, `environment` |
| `terraform.tfvars` | Values for those variables |
| `main.tf` | Bucket + versioning + public access block + SSE (AES256) |
| `outputs.tf` | `bucket_name`, `bucket_arn`, `bucket_region` |

**Unique name.** S3 bucket names are global across all AWS accounts. The bucket uses `bucket_prefix`
instead of `bucket`, so AWS appends a unique suffix (this run got `bibek-s18-demo-419bd109722899a4de97fb3592`).
Two people can apply this code without a name clash.

**Security.** Versioning keeps old object versions. The public access block stops any public ACL or
policy. Default encryption uses SSE-S3 (AES256). `force_destroy = true` lets `terraform destroy` delete a
non-empty bucket. Use it only for demos.

## Workflow

Every command ran for real against AWS (IAM user with `AmazonS3FullAccess`, region `ap-south-1`).
Output is pasted as printed. Long output is cut with `...`. The 12-digit AWS account ID is replaced
with `<ACCOUNT_ID>` wherever it appears.

### 1. terraform version
```
$ terraform version
Terraform v1.16.1
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.16.5. You can update by downloading from https://developer.hashicorp.com/terraform/install
```

### 2. terraform init
```
$ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0"...
- Installing hashicorp/aws v6.67.0...
- Installed hashicorp/aws v6.67.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
...
```

### 3. terraform fmt
```
$ terraform fmt
```
No output: every file was already formatted (exit code 0). `fmt` prints only the names of files it changes.

### 4. terraform validate
```
$ terraform validate
Success! The configuration is valid.
```

### 5. terraform plan
```
$ terraform plan -out=s18.tfplan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      ...
      + bucket_prefix               = "bibek-s18-demo-"
      ...
      + force_destroy               = true
      ...
      + region                      = "ap-south-1"
      ...
    }

  # aws_s3_bucket_public_access_block.demo will be created
  + resource "aws_s3_bucket_public_access_block" "demo" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + region                  = "ap-south-1"
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.demo will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
      ...
          + apply_server_side_encryption_by_default {
              + kms_master_key_id = (known after apply)
              + sse_algorithm     = "AES256"
            }
        }
    }

  # aws_s3_bucket_versioning.demo will be created
  + resource "aws_s3_bucket_versioning" "demo" {
      ...
      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_arn    = (known after apply)
  + bucket_name   = (known after apply)
  + bucket_region = "ap-south-1"

─────────────────────────────────────────────────────────────────────────────

Saved the plan to: s18.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "s18.tfplan"
```

### 6. terraform apply
```
$ terraform apply s18.tfplan
aws_s3_bucket.demo: Creating...
aws_s3_bucket.demo: Creation complete after 3s [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_versioning.demo: Creating...
aws_s3_bucket_public_access_block.demo: Creating...
aws_s3_bucket_server_side_encryption_configuration.demo: Creating...
aws_s3_bucket_public_access_block.demo: Creation complete after 1s [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_server_side_encryption_configuration.demo: Creation complete after 1s [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_versioning.demo: Creation complete after 2s [id=bibek-s18-demo-419bd109722899a4de97fb3592]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_name = "bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_region = "ap-south-1"
```

Proof that the bucket exists in AWS:
```
$ aws s3 ls
2026-10-07 22:49:58 bibek-s18-demo-419bd109722899a4de97fb3592
```
(Only this bucket's line is shown.)

### 7. terraform show
```
$ terraform show
# aws_s3_bucket.demo:
resource "aws_s3_bucket" "demo" {
    acceleration_status         = null
    arn                         = "arn:aws:s3:::bibek-s18-demo-419bd109722899a4de97fb3592"
    bucket                      = "bibek-s18-demo-419bd109722899a4de97fb3592"
    bucket_domain_name          = "bibek-s18-demo-419bd109722899a4de97fb3592.s3.amazonaws.com"
    bucket_namespace            = "global"
    bucket_prefix               = "bibek-s18-demo-"
    bucket_region               = "ap-south-1"
    bucket_regional_domain_name = "bibek-s18-demo-419bd109722899a4de97fb3592.s3.ap-south-1.amazonaws.com"
    force_destroy               = true
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    id                          = "bibek-s18-demo-419bd109722899a4de97fb3592"
    object_lock_enabled         = false
    policy                      = null
    region                      = "ap-south-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "Environment" = "dev"
        "ManagedBy"   = "Terraform"
        "Project"     = "Session18"
    }
    ...
    versioning {
        enabled    = false
        mfa_delete = false
    }
}

# aws_s3_bucket_public_access_block.demo:
resource "aws_s3_bucket_public_access_block" "demo" {
    block_public_acls       = true
    block_public_policy     = true
    bucket                  = "bibek-s18-demo-419bd109722899a4de97fb3592"
    id                      = "bibek-s18-demo-419bd109722899a4de97fb3592"
    ignore_public_acls      = true
    region                  = "ap-south-1"
    restrict_public_buckets = true
}

# aws_s3_bucket_server_side_encryption_configuration.demo:
resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
    bucket                = "bibek-s18-demo-419bd109722899a4de97fb3592"
    expected_bucket_owner = null
    id                    = "bibek-s18-demo-419bd109722899a4de97fb3592"
    region                = "ap-south-1"

    rule {
        blocked_encryption_types = [
            "SSE-C",
        ]
        bucket_key_enabled       = false

        apply_server_side_encryption_by_default {
            kms_master_key_id = null
            sse_algorithm     = "AES256"
        }
    }
}

# aws_s3_bucket_versioning.demo:
resource "aws_s3_bucket_versioning" "demo" {
    bucket                = "bibek-s18-demo-419bd109722899a4de97fb3592"
    expected_bucket_owner = null
    id                    = "bibek-s18-demo-419bd109722899a4de97fb3592"
    region                = "ap-south-1"

    versioning_configuration {
        mfa_delete = "Disabled"
        status     = "Enabled"
    }
}


Outputs:

bucket_arn = "arn:aws:s3:::bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_name = "bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_region = "ap-south-1"
```

The bucket's own `versioning { enabled = false }` block is stale. Terraform read the bucket before the
separate `aws_s3_bucket_versioning` resource turned versioning on. The versioning resource shows the
real setting: `status = "Enabled"`. A `terraform refresh` would update the stale value.

### 8. terraform output
```
$ terraform output
bucket_arn = "arn:aws:s3:::bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_name = "bibek-s18-demo-419bd109722899a4de97fb3592"
bucket_region = "ap-south-1"
```

### 9. terraform destroy
```
$ terraform destroy -auto-approve
aws_s3_bucket.demo: Refreshing state... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_public_access_block.demo: Refreshing state... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_versioning.demo: Refreshing state... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_server_side_encryption_configuration.demo: Refreshing state... [id=bibek-s18-demo-419bd109722899a4de97fb3592]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket.demo will be destroyed
  - resource "aws_s3_bucket" "demo" {
...
Plan: 0 to add, 0 to change, 4 to destroy.

Changes to Outputs:
  - bucket_arn    = "arn:aws:s3:::bibek-s18-demo-419bd109722899a4de97fb3592" -> null
  - bucket_name   = "bibek-s18-demo-419bd109722899a4de97fb3592" -> null
  - bucket_region = "ap-south-1" -> null
aws_s3_bucket_public_access_block.demo: Destroying... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_versioning.demo: Destroying... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_server_side_encryption_configuration.demo: Destroying... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket_server_side_encryption_configuration.demo: Destruction complete after 1s
aws_s3_bucket_versioning.demo: Destruction complete after 1s
aws_s3_bucket_public_access_block.demo: Destruction complete after 1s
aws_s3_bucket.demo: Destroying... [id=bibek-s18-demo-419bd109722899a4de97fb3592]
aws_s3_bucket.demo: Destruction complete after 1s

Destroy complete! Resources: 4 destroyed.
```

Proof that the bucket is gone:
```
$ aws s3 ls | grep bibek-s18
$ terraform state list
```
Both commands print nothing. `grep` exits with code 1 (no match), and the state holds no resources.

## How to run it yourself

1. Set credentials with `aws configure`, or export `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
   and `AWS_DEFAULT_REGION=ap-south-1`.
2. Check them with `aws sts get-caller-identity`.
3. Run `terraform init`, `terraform plan -out=s18.tfplan`, `terraform apply s18.tfplan`,
   `terraform output`, then `terraform destroy`.

The IAM user needs S3 permissions. Never commit keys. `terraform.tfstate` is git-ignored because it can
hold sensitive values.
