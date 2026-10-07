# 04 — VPC (Virtual Private Cloud) — Networking

## What is VPC?
A VPC is your own isolated private network inside one AWS region. You choose its IP range and split it
into subnets. EC2, RDS, load balancers and similar resources run inside a VPC. Every region has a
default VPC.

## CIDR
CIDR notation gives an IP range: `10.0.0.0/16` means the first 16 bits are fixed, so 65,536 addresses.
A VPC can be /16 (largest) to /28 (16 addresses). Use private ranges (`10.0.0.0/8`, `172.16.0.0/12`,
`192.168.0.0/16`) and do not overlap ranges you may peer or connect with later. AWS reserves 5 addresses
in every subnet (first four and last).

## Subnets
A subnet is a part of the VPC range in **one** Availability Zone, for example `10.0.1.0/24` in
`ap-south-1a`. For high availability, put subnets in two or more AZs.

## Route tables
A route table decides where traffic from a subnet goes. Each subnet is associated with one table. Every
table has a `local` route for traffic inside the VPC. The most specific matching route wins.

| Destination | Target | Meaning |
|---|---|---|
| `10.0.0.0/16` | local | Inside the VPC |
| `0.0.0.0/0` | igw-... | Internet (public subnet) |
| `0.0.0.0/0` | nat-... | Outbound internet only (private subnet) |

## Internet Gateway
An internet gateway (IGW) connects the VPC to the internet in both directions. One per VPC. It is
highly available and costs nothing. An instance needs a public IP and a route to the IGW to be reached.

## NAT Gateway
A NAT gateway lets instances in private subnets start connections to the internet (for updates,
external APIs). The internet cannot start connections back. It sits in a public subnet with an Elastic
IP. It is zonal and charged per hour and per GB, so production uses one per AZ.

## Security Groups
Stateful firewall at the instance (network interface) level. Allow rules only. Return traffic is
allowed automatically. All rules are evaluated together.

## Network ACLs
Stateless firewall at the subnet level. Has both allow and deny rules, evaluated in number order (first
match wins). Because it is stateless, you must allow return traffic too (ephemeral ports 1024–65535).

| | Security Group | Network ACL |
|---|---|---|
| Level | Instance (ENI) | Subnet |
| State | Stateful | Stateless |
| Rules | Allow only | Allow and deny |
| Order | All evaluated | Lowest number first |
| Default | Deny in, allow out | Default NACL allows all |

## Public vs private subnet
A **public subnet** has a route `0.0.0.0/0 → internet gateway`. Put load balancers and bastion hosts
here. A **private subnet** has no route to the IGW; it may have `0.0.0.0/0 → NAT gateway` for outbound
traffic only. Put app servers and databases here. "Public" is set by the route table, not by a flag on
the subnet.

## Example (not run)
Terraform: a VPC with one public subnet.
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
```
