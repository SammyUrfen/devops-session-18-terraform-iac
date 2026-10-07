# 01 — IAM (Identity and Access Management) — Governance

## What is IAM?
IAM is the AWS service that controls **who** can do **what** on **which** resources. It is global (not
per region) and free. Every AWS API call is checked against IAM. By default everything is denied.

## Users
A user is one identity for one person or app. It has long-term credentials: a console password and/or
access keys. Do not use the root user (the email that opened the account) for daily work.

## Groups
A group is a set of users. You attach policies to the group, and every member gets them. Example: a
`developers` group. A group cannot contain other groups, and it cannot be used to sign in.

## Roles
A role is an identity with no password or long-term keys. A trusted entity *assumes* it and gets
temporary credentials from STS. Users, AWS services (EC2, Lambda), other accounts, and SSO/OIDC
identities (for example GitHub Actions) can assume roles. A role has two policies: a **trust policy**
(who can assume it) and **permission policies** (what it can do).

## Policies
A policy is a JSON document with statements. Each statement has `Effect` (Allow/Deny), `Action`,
`Resource`, and optional `Condition`.

| Type | Meaning |
|---|---|
| AWS managed | Written by AWS, for example `ReadOnlyAccess` |
| Customer managed | Written by you, reusable |
| Inline | Embedded in one user/group/role only |
| Resource-based | Attached to a resource, for example an S3 bucket policy |
| Permission boundary / SCP | Set the maximum permissions; they never grant |

## Permissions
AWS evaluates all policies that apply. The rule: an explicit **Deny** always wins. Otherwise an explicit
**Allow** is needed. If nothing allows the action, it is denied (implicit deny).

## Least privilege
Give only the actions and resources a job needs, and nothing more. Start small and add permissions when
an access error shows a real need. IAM Access Analyzer can generate a policy from actual CloudTrail use.

## IAM best practices
- Lock the root user: enable MFA, delete its access keys, use it only for root-only tasks.
- Enable MFA for every human user.
- Prefer roles and temporary credentials (IAM Identity Center/SSO) over long-term access keys.
- Give EC2/Lambda a role, never hard-coded keys.
- Attach policies to groups or roles, not to single users.
- Rotate or remove unused keys and users (use the credential report and last-accessed data).
- Use conditions (source IP, MFA, tags) and permission boundaries where useful.
- Log all API calls with CloudTrail.

## Common use cases
- Team access: one group per job role (admins, developers, read-only auditors).
- An EC2 instance reads an S3 bucket through an instance role.
- CI/CD (GitHub Actions) deploys through an OIDC role, with no stored keys.
- Cross-account access: an account in the organisation assumes a role in another account.

## Example (not run)
Terraform: a role that EC2 can assume, with read-only access to one bucket.
```hcl
resource "aws_iam_role" "app" {
  name = "app-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "read_bucket" {
  role = aws_iam_role.app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::my-app-bucket", "arn:aws:s3:::my-app-bucket/*"]
    }]
  })
}
```
