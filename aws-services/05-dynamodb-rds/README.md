# 05 — DynamoDB & RDS — Database Services

# DynamoDB

## NoSQL
DynamoDB is a fully managed NoSQL key-value and document database. There are no servers to manage. It
gives single-digit millisecond reads and writes at any scale. There are no joins and no fixed schema
(only the key is fixed). You design tables around your access patterns. Capacity modes: **on-demand**
(pay per request) or **provisioned** (set read/write units, optional auto scaling).

## Tables
A table is a collection of items. You define only the primary key when you create it. Data is copied
across three AZs in the region automatically.

## Items
An item is one record, like a row. The maximum item size is 400 KB. Each item must have the primary
key; other attributes can differ between items.

## Attributes
An attribute is a named value on an item. Types: scalar (String, Number, Binary, Boolean, Null),
document (List, Map), and set (String/Number/Binary set).

## Partition key
The partition key (hash key) is required. DynamoDB hashes it to choose the physical partition that
stores the item. Pick a key with many distinct values so load spreads evenly. A few very busy keys
cause "hot partitions". If the table has only a partition key, it must be unique.

## Sort key
The sort key (range key) is optional. Items with the same partition key are stored together, sorted by
the sort key. Partition key + sort key must be unique. You can query a range: `begins_with`, `between`,
`<`, `>`. Example: partition key `customer_id`, sort key `order_date`.

Secondary indexes (GSI, LSI) let you query by other attributes.

## Use cases
- Session stores, shopping carts, user profiles.
- Gaming leaderboards, IoT data, ad tech — high scale with key lookups.
- Serverless backends with Lambda.
- Terraform state locking (older setups; newer Terraform can lock in S3).

## Example (not run)
```bash
aws dynamodb create-table --table-name Orders \
  --attribute-definitions AttributeName=customer_id,AttributeType=S AttributeName=order_date,AttributeType=S \
  --key-schema AttributeName=customer_id,KeyType=HASH AttributeName=order_date,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

# RDS (Relational Database Service)

## Relational database
RDS runs a managed relational (SQL) database. Data is in tables with a fixed schema, rows and columns,
joins and ACID transactions. AWS handles provisioning, OS and engine patching, backups and failover.
You handle schema, queries, and tuning. You cannot SSH to the host.

## Supported engines
- PostgreSQL
- MySQL
- MariaDB
- Oracle
- Microsoft SQL Server
- IBM Db2
- Amazon Aurora (MySQL- and PostgreSQL-compatible; AWS-built storage, part of the RDS family)

## DB instances
A DB instance is one database server: an instance class (for example `db.t4g.micro`, `db.m7g.large`),
storage (`gp3`, `io2`), an engine version, and an endpoint (DNS name and port) apps connect to. You
can scale the class or storage later.

## Security
- Put the instance in **private subnets** (a DB subnet group) with "publicly accessible" off.
- Security groups allow the DB port only from the app's security group.
- Encryption at rest with KMS (choose at creation). TLS in transit.
- Master password in Secrets Manager (RDS can manage and rotate it), or IAM database authentication.
- IAM controls who can manage the instance (create, delete, snapshot).

## Backups
- **Automated backups**: daily snapshot plus transaction logs, retention 1–35 days. Gives
  point-in-time restore (to any second, usually up to the last 5 minutes).
- **Manual snapshots**: kept until you delete them. Can be copied to other regions or accounts.
- A restore always creates a **new** DB instance.

## Multi-AZ
RDS keeps a synchronous standby copy in another AZ. If the primary or its AZ fails, RDS fails over
automatically (usually 1–2 minutes) and the same endpoint points to the standby. The classic standby
does not serve reads. It is for availability, not scaling. (A Multi-AZ *cluster* option has two
readable standbys.)

## Read replicas
Read replicas get **asynchronous** copies of the data. They serve read-only queries to spread read load,
can be in another region, and can be promoted to standalone databases (for example in disaster
recovery). They have their own endpoints, and they can lag behind the primary.

| | Multi-AZ | Read replica |
|---|---|---|
| Purpose | High availability | Read scaling |
| Replication | Synchronous | Asynchronous |
| Serves reads | No (classic) | Yes |
| Failover | Automatic | Manual promote |

## Use cases
- Web and mobile app backends that need SQL and transactions.
- E-commerce orders, payments, inventory.
- ERP/CRM systems, existing apps moved off self-hosted MySQL/PostgreSQL/Oracle.

## Example (not run)
```hcl
resource "aws_db_instance" "app" {
  identifier                  = "app-db"
  engine                      = "postgres"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  username                    = "appadmin"
  manage_master_user_password = true # password kept in Secrets Manager
  multi_az                    = true
  storage_encrypted           = true
  backup_retention_period     = 7
  publicly_accessible         = false
  skip_final_snapshot         = true # demo only
}
```

# DynamoDB vs RDS

| | DynamoDB | RDS |
|---|---|---|
| Model | NoSQL key-value / document | Relational SQL |
| Schema | Only the key is fixed | Fixed tables and columns |
| Queries | By key and indexes, no joins | Any SQL, joins |
| Scaling | Automatic, near unlimited | Bigger instance + read replicas |
| Servers | None (serverless) | You pick instance size |
| Best for | Known access patterns at high scale | Complex queries and relations |
