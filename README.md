# Book Review App - Terraform Infrastructure

This repository contains a complete Terraform scaffold for deploying a three-tier web application on AWS with load balancing, auto-scaling capabilities, and RDS database.

## Architecture Overview

![Architectural Diagram](assets/architetural-diagram.jpeg)



## Project Structure

```
book-review-terraform-Iac/
├── main.tf                 # Root module configuration - orchestrates all modules
├── variables.tf            # Root-level variable definitions
├── outputs.tf              # Root-level outputs (VPC, instance IDs, endpoints)
├── terraform.tfvars        # Variable values (EXCLUDED from git - add your values here)
├── .gitignore             # Git ignore rules for sensitive files
├── DEPLOYMENT_GUIDE.md    # Step-by-step deployment instructions
├── README.md              # This file
│
└── modules/               # Modular infrastructure components
    ├── networking/        # VPC, subnets, gateways
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security/          # Security groups and rules
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2/              # EC2 instances (web and app servers)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── alb/              # Application Load Balancers
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── database/         # RDS (MySQL)
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Descriptions

### 1. **networking** (`modules/networking/`)
Creates the network foundation for the application.

**Creates:**
- VPC (Virtual Private Cloud)
- Public subnets (2): For web tier
- Private subnets (2): For app tier
- Private subnets (2): For database tier
- Internet Gateway: Public internet access
- NAT Gateway: Outbound internet for private subnets
- Route tables and associations

**Dependencies:** None (foundational)

---

### 2. **security** (`modules/security/`)
Defines security groups and firewall rules for all tiers.

**Creates Security Groups for:**
- **pub_alb_sg**: Public ALB (allows port 80 from anywhere)
- **web_sg**: Web servers (allows port 80 from ALB, SSH from anywhere)
- **internal_alb_sg**: Internal ALB (allows port 3001 from web tier)
- **app_sg**: App servers (allows port 3001 from internal ALB, SSH from web tier)
- **db_sg**: Database (allows port 3306 from app tier only)

**Dependencies:** VPC (from networking module)

---

### 3. **ec2** (`modules/ec2/`)
Provisions EC2 instances for web and app tiers.

**Creates:**
- **Web Server**: Public instance in web subnet (port 80)
- **App Server**: Private instance in app subnet (port 3001)
- Uses latest Ubuntu 24.04 AMI
- SSH key pair for management

**Key Features:**
- Web server has public IP and internet access
- App server is private with NAT gateway access
- Both use security groups from security module

**Dependencies:** VPC subnets, security groups

---

### 4. **alb** (`modules/alb/`)
Sets up application load balancers for traffic distribution.

**Creates:**
- **Public ALB**: Receives traffic on port 80, routes to web tier
- **Internal ALB**: Receives traffic on port 3001 from web tier, routes to app tier
- **Target Groups**: Define health checks and instance targets
- **Health Checks**: Monitor instance health

**Health Check Configuration:**
- Web targets: Check `/` path, expects 200 status
- App targets: Check `/health` path, expects 200 status
  - ⚠️ **Important**: Ensure your app has a `/health` endpoint

**Dependencies:** VPC, security groups, EC2 instances

---

### 5. **database** (`modules/database/`)
Creates managed RDS MySQL database instance.

**Creates:**
- RDS MySQL instance (recommended: db.t3.micro for dev)
- Multi-AZ for production reliability
- Automated backups (7 days retention)
- Encryption at rest
- Database and user creation

**Configuration:**
- Port: 3306 (MySQL default)
- Engine: MySQL 8.0
- Storage: 20 GB (configurable)

**Dependencies:** VPC subnets, security groups

---

## File Descriptions

### Root Level Files

**`main.tf`**
- Configures AWS provider
- Calls all 5 modules in the correct order
- Passes outputs from one module to another

**`variables.tf`**
- Defines all input variables (type, description, defaults)
- Variables are passed through `terraform.tfvars`

**`outputs.tf`**
- Exports important values (VPC ID, instance IDs, endpoints)
- Useful for accessing values after deployment: `terraform output`

**`terraform.tfvars`**
- Contains actual values for all variables
- ⚠️ **Add to `.gitignore`** - DO NOT commit (contains secrets)
- Create from `terraform.tfvars.example` (if provided)

### Module Pattern

Each module follows the same structure:

**`variables.tf`** - Module inputs
```hcl
variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}
```

**`main.tf`** - Resource definitions
```hcl
resource "aws_instance" "web_server" {
  # Resource configuration
}
```

**`outputs.tf`** - Module outputs
```hcl
output "instance_id" {
  value = aws_instance.web_server.id
}
```

## What to Set Up First

Follow this order for initial setup:

### Step 0: Prerequisites
```bash
# Install Terraform (v1.0+)
terraform --version

# Install AWS CLI v2
aws --version

# Configure AWS credentials
aws configure
# or set environment variables:
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...
# export AWS_DEFAULT_REGION=us-east-1
```

### Step 1: Create SSH Key Pair
```bash
# Create key pair in AWS (saves to .pem file)
aws ec2 create-key-pair --key-name <key name> --region <region> --query 'KeyMaterial' --output text > keyname.pem
chmod 400 keyname.pem
```

### Step 2: Configure Variables
```bash
# Copy template (if exists) or create new
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
nano terraform.tfvars
```

**Required values in `terraform.tfvars`:**
```hcl
aws_region         = "us-east-1"
project            = "book-review"  # Used for resource naming
vpc_cidr_block     = "10.0.0.0/16"

# Subnet CIDR blocks (must be within VPC CIDR)
web_subnet_1_cidr  = "10.0.1.0/24"
web_subnet_2_cidr  = "10.0.2.0/24"
app_subnet_1_cidr  = "10.0.10.0/24"
app_subnet_2_cidr  = "10.0.11.0/24"
db_subnet_1_cidr   = "10.0.20.0/24"
db_subnet_2_cidr   = "10.0.21.0/24"

# Instance types
web_instance_type  = "t3.micro"    # Free tier eligible
app_instance_type  = "t3.small"

# Key pair name (created in Step 1)
keyname            = "my-app-key"

# Database configuration
allocated_storage  = 20
db_name            = "bookreview"
engine             = "mysql"
engine_version     = "8.0"
instance_class     = "db.t3.micro"
username           = "admin"
password           = "YourSecurePassword123!"  # Change this!
```

### Step 3: Initialize Terraform
```bash
terraform init
# Downloads AWS provider plugin and initializes working directory
```

### Step 4: Validate Configuration
```bash
terraform validate
# Checks syntax and configuration for errors
```

### Step 5: Plan Deployment
```bash
terraform plan
# Shows what will be created (review before applying)
```

### Step 6: Deploy Infrastructure
```bash
terraform apply
# Creates all resources on AWS
# Type 'yes' when prompted
```

### Step 7: Verify Deployment
```bash
# View outputs
terraform output

# SSH to web server
terraform output -raw web_server_public_ip
ssh -i my-app-key.pem ubuntu@<web-ip>

# Get RDS endpoint
terraform output -raw rds_endpoint
```

## Important Configuration Notes

### Health Check Endpoints
- **Web servers** `/` should return HTTP 200
- **App servers** `/health` should return HTTP 200
  - If your app doesn't have `/health`, modify `modules/alb/main.tf`

### Database Password
- Change the default password in `terraform.tfvars`
- Store securely (use AWS Secrets Manager for production)

### Networking CIDR Blocks
All subnet CIDR blocks must be within the VPC CIDR block:
- VPC: `10.0.0.0/16`
- Web subnets: `10.0.1.0/24`, `10.0.2.0/24`
- App subnets: `10.0.10.0/24`, `10.0.11.0/24`
- DB subnets: `10.0.20.0/24`, `10.0.21.0/24`

## Common Tasks

### View All Outputs
```bash
terraform output
```

### Destroy Everything
```bash
terraform destroy
# Type 'yes' when prompted
```

### Destroy Specific Resource
```bash
terraform destroy -target=module.database.aws_db_instance.main
```

### Update Configuration
```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### View Current State
```bash
terraform state list          # List all resources
terraform state show <resource_name>  # Details of specific resource
```

## Troubleshooting

**Q: "The specified key pair does not exist"**
- A: Create the key pair (see Step 1) or use existing one

**Q: "Insufficient capacity in availability zone"**
- A: Change instance type or region

**Q: "App server health check failing"**
- A: Ensure `/health` endpoint exists on app server or update health check path

**Q: "Cannot connect to database"**
- A: Verify app server has outbound security group rule to DB security group

**Q: "terraform init fails"**
- A: Ensure AWS credentials are configured: `aws configure` or environment variables

## Next Steps

1. Read [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed deployment steps
2. Deploy following the "What to Set Up First" section above
3. Connect to instances and verify application deployment
4. Configure your application to use the RDS endpoint
5. Set up monitoring and logging (AWS CloudWatch)

## Variable Reference

See `variables.tf` for complete variable definitions including:
- Type constraints
- Default values  
- Descriptions
- Validation rules

## Security Considerations

- ✅ SSH restricted appropriately (web tier only, app tier from web tier)
- ✅ Database only accessible from app tier
- ✅ Secrets excluded from git (`.gitignore`)
- ⚠️ Change RDS password in production
- ⚠️ Restrict SSH CIDR blocks (don't use 0.0.0.0/0 in production)
- ⚠️ Enable encryption and backups for production RDS

## Support & Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)
