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
instead of `bucket`, so AWS appends a unique suffix (for example `bibek-s18-demo-2026...`). Two people can
apply this code without a name clash.

**Security.** Versioning keeps old object versions. The public access block stops any public ACL or
policy. Default encryption uses SSE-S3 (AES256). `force_destroy = true` lets `terraform destroy` delete a
non-empty bucket. Use it only for demos.

## Workflow — steps that ran

No AWS credentials exist on this machine yet. `init`, `fmt` and `validate` do not call AWS, so they ran
for real. Output is pasted as printed.

```
$ terraform version
Terraform v1.16.1
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.16.5. You can update by downloading from https://developer.hashicorp.com/terraform/install
```

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

```
$ terraform fmt
```
No output: every file was already formatted (exit code 0). `fmt` prints only the names of files it changes.

```
$ terraform validate
Success! The configuration is valid.
```

## Workflow — steps pending AWS

These steps call the AWS API. They have not run. No output is shown on purpose.

| Step | Command | What it does |
|---|---|---|
| Plan | `terraform plan -out=s18.tfplan` | Shows the 4 resources to create, saves the plan |
| Apply | `terraform apply s18.tfplan` | Creates the bucket and its 3 settings |
| Show | `terraform show` | Prints the resources in the state file |
| Output | `terraform output` | Prints `bucket_name`, `bucket_arn`, `bucket_region` |
| Destroy | `terraform destroy` | Deletes everything (type `yes`) |

### terraform plan
```
$ terraform plan -out=s18.tfplan
```
> **Pending: run after AWS credentials are configured.**

### terraform apply
```
$ terraform apply s18.tfplan
```
> **Pending: run after AWS credentials are configured.**

### terraform show
```
$ terraform show
```
> **Pending: run after AWS credentials are configured.**

### terraform output
```
$ terraform output
```
> **Pending: run after AWS credentials are configured.**

### terraform destroy
```
$ terraform destroy
```
> **Pending: run after AWS credentials are configured.**

## How to run once AWS is ready

1. Install the AWS CLI v2 (Fedora: `sudo dnf install awscli2`).
2. Give Terraform credentials. Use one of these:
   - `aws configure` — enter the access key ID, secret key, region `ap-south-1`, output `json`.
   - Environment variables in the current shell:
     ```
     export AWS_ACCESS_KEY_ID=...
     export AWS_SECRET_ACCESS_KEY=...
     export AWS_DEFAULT_REGION=ap-south-1
     ```
3. Check the identity: `aws sts get-caller-identity`.
4. Run, from this folder:
   ```
   terraform plan -out=s18.tfplan
   terraform apply s18.tfplan
   terraform show
   terraform output
   terraform destroy
   ```
5. Paste each output into the pending sections above.

The IAM user needs S3 permissions (for example `AmazonS3FullAccess` on a lab account). Never commit
keys. `terraform.tfstate` is git-ignored because it can hold sensitive values.
