# 03 — S3 (Simple Storage Service) — Storage

## What is S3?
S3 is object storage. You store files (objects) in containers (buckets) and reach them by HTTPS API.
It is designed for 99.999999999% (11 nines) durability. There is no fixed size limit for a bucket.
It is not a file system: you cannot edit part of an object in place.

## Buckets
A bucket holds objects. Its name is unique across all AWS accounts worldwide, 3–63 characters,
lowercase. A bucket lives in one region. New buckets block public access and encrypt by default.

## Objects
An object is data plus metadata, found by its **key** (for example `logs/2026/app.log`). The `/` only
looks like folders; the namespace is flat. One object can be up to 50 TB. Use multipart upload for
large files.

## Storage classes
| Class | Use | Note |
|---|---|---|
| Standard | Frequent access | Default |
| Intelligent-Tiering | Unknown pattern | Moves objects between tiers automatically |
| Standard-IA | Infrequent access | Retrieval fee, 30-day minimum |
| One Zone-IA | Infrequent, re-creatable data | One AZ only |
| Glacier Instant Retrieval | Archive, read in ms | 90-day minimum |
| Glacier Flexible Retrieval | Archive, read in minutes–hours | 90-day minimum |
| Glacier Deep Archive | Long-term archive, read in hours | Cheapest, 180-day minimum |

## Versioning
With versioning on, every overwrite keeps the old version and a delete adds a "delete marker" instead of
removing data. You can restore old versions. Once enabled, it can only be suspended, not turned off.
Old versions cost storage, so pair it with lifecycle rules.

## Lifecycle policies
Rules that act on objects by age, prefix or tag:
- **Transition**: move to a cheaper class (for example to Standard-IA after 30 days, Glacier after 90).
- **Expiration**: delete objects or old versions after N days.
- Clean up incomplete multipart uploads.

## Encryption
- In transit: HTTPS (TLS). A bucket policy can deny non-HTTPS requests (`aws:SecureTransport`).
- At rest: SSE-S3 (AES-256, AWS keys, default for all new objects), SSE-KMS (your KMS key, audit
  in CloudTrail), DSSE-KMS (two layers), SSE-C (you send the key with each request).
- Client-side encryption: you encrypt before upload.

## Bucket policies
A bucket policy is a resource-based JSON policy on the bucket. It can grant access to other accounts,
roles or services, or deny access (for example deny non-HTTPS). The Block Public Access setting
overrides any policy that would make the bucket public. AWS recommends turning off ACLs ("bucket
owner enforced") and using policies only.

## Common use cases
- Backups and archives.
- Static website hosting (often behind CloudFront).
- Data lakes for Athena / analytics.
- Log storage (CloudTrail, ALB logs).
- Terraform remote state (with locking).
- App uploads such as images and videos.

## Example (not run)
AWS CLI: create a bucket, enable versioning, upload a file.
```bash
aws s3api create-bucket --bucket my-demo-bucket-12345 --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
aws s3api put-bucket-versioning --bucket my-demo-bucket-12345 \
  --versioning-configuration Status=Enabled
aws s3 cp notes.txt s3://my-demo-bucket-12345/docs/notes.txt
```
The Terraform version of this bucket is in [`../../terraform-s3-demo`](../../terraform-s3-demo).
