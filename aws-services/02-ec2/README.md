# 02 — EC2 (Elastic Compute Cloud) — Compute

## What is EC2?
EC2 gives you virtual machines (instances) in AWS. You choose the OS, CPU, memory, disk and network,
and you pay per second (Linux) while the instance runs. You manage the OS yourself.

## AMI (Amazon Machine Image)
An AMI is the template for the root disk: OS plus any preinstalled software. Examples: Amazon Linux
2023, Ubuntu. AMIs are regional, so an AMI ID differs per region. You can create your own AMI from an
instance.

## Instance types
The type sets CPU, memory, network and sometimes GPU. Name format: family + generation + size, for
example `t3.micro`.

| Family | Optimised for | Example |
|---|---|---|
| T | Burstable, general | `t3.micro` |
| M | General purpose, balanced | `m7i.large` |
| C | Compute | `c7g.xlarge` |
| R / X | Memory | `r7i.large` |
| I / D | Local storage | `i4i.large` |
| P / G | GPU | `g5.xlarge` |

A `g` after the generation (for example `c7g`) means an ARM Graviton CPU.

## Key pairs
A key pair is used for SSH login. AWS stores the public key and puts it in the instance. You keep the
private key (`.pem`) and AWS cannot show it again. Windows uses it to decrypt the admin password.
EC2 Instance Connect and SSM Session Manager are alternatives that need no stored key.

## Security Groups
A security group is a stateful virtual firewall on the instance's network interface. It has only
**allow** rules. Inbound is denied by default and outbound is allowed by default. Stateful means reply
traffic is allowed automatically. A rule can name another security group as the source.

## EBS (Elastic Block Store)
EBS is a network disk attached to one instance in the same Availability Zone. It keeps data when the
instance stops. Types: `gp3` (general SSD), `io2` (high IOPS SSD), `st1`/`sc1` (HDD). Snapshots back up
a volume to S3. Instance store, by contrast, is local disk that loses its data when the instance stops.

## Public vs private IP
| | Private IP | Public IP | Elastic IP |
|---|---|---|---|
| Reachable from | Inside the VPC | The internet | The internet |
| Changes on stop/start | No | Yes | No |
| Cost | Free | Charged per hour (IPv4) | Charged per hour |

Every instance has a private IP. A public IP needs a public subnet with a route to an internet gateway.

## Instance lifecycle
`pending` → `running` → `stopping` → `stopped` → (start) → `pending` ...
`running` → `shutting-down` → `terminated` (permanent; root EBS deleted by default).
Reboot keeps the same host and IPs. Stop/start can move to new hardware and changes the public IP. You
pay compute only in `running`, but EBS volumes cost money while stopped. Hibernate saves RAM to EBS.

## Common use cases
- Web and app servers, often behind a load balancer in an Auto Scaling group.
- Self-managed databases, CI build agents, batch jobs.
- GPU instances for ML training.
- Kubernetes worker nodes (EKS).

## Example (not run)
AWS CLI: launch one small instance.
```bash
aws ec2 run-instances \
  --image-id ami-0123456789abcdef0 \
  --instance-type t3.micro \
  --key-name my-key \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo}]'
```
The IDs are placeholders.
