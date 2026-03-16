## ACS730 – Assignment 1: Terraform Multi‑Environment Infrastructure

This directory contains Terraform code to deploy a **multi‑environment AWS infrastructure** for the ACS730 assignment.

![Architecture Diagram](diagram.png)

It creates:

- **nonprod VPC**: 2 public + 2 private subnets, Internet Gateway, NAT Gateway, a bastion host in a public subnet, and 2 EC2 instances (VM1, VM2) in private subnets running Apache and serving a custom page.
- **prod VPC**: 2 private subnets, no public subnets, 2 EC2 instances (VM1, VM2) in private subnets without extra software.
- **VPC peering** between nonprod and prod VPCs with routing so traffic can flow between the environments.

The Terraform code is modular and uses **remote S3 state** to separate nonprod, prod, and peering.

---

## 1. Directory Structure

All Terraform code is under `terraform_code/`:

- **`environments/nonprod/`**
  - `backend.tf` – S3 backend configuration for nonprod state  
  - `main.tf` – nonprod VPC, bastion host, EC2 instances (Apache web servers)  
  - `variables.tf` – input variables for nonprod  
  - `terraform.tfvars.example` – example values; copy and edit for your deployment  
  - `nonprod-userdata.sh.tpl` – user data to install/configure Apache and render the custom message
- **`environments/prod/`**
  - `backend.tf` – S3 backend configuration for prod state  
  - `main.tf` – prod VPC and EC2 instances  
  - `variables.tf` – input variables for prod  
  - `terraform.tfvars.example` – example values; copy and edit for your deployment  
  - `prod-userdata.sh.tpl` – user data for prod (no extra packages beyond what is required)
- **`environments/peering/`**
  - `main.tf` – VPC peering module, uses **remote state** from nonprod and prod  
  - `variables.tf` – input variables for peering (state bucket and VPC CIDRs)  
  - `terraform.tfvars.example` – example values; copy and edit for your deployment
- **`modules/network/`** – creates VPCs, subnets, route tables, gateways (modular network layer)
- **`modules/ec2/`** – creates EC2 instances, security groups, and associates user data
- **`modules/bastion/`** – creates bastion host and associated security group
- **`modules/peering/`** – creates VPC peering connection and updates route tables

---

## 2. Prerequisites

Before running Terraform, ensure you have:

- **AWS account** with permissions to create:
  - VPCs, subnets, Internet Gateways, NAT Gateways, route tables, and routes
  - EC2 instances, security groups, key pairs
  - S3 buckets (for Terraform remote state)
- **AWS Cloud9 environment** (or another Linux shell) with:
  - AWS CLI configured with sufficient IAM permissions.
  - Terraform CLI installed (v1.x or later).
- **S3 bucket for remote state**:
  - The backends in this code are currently configured to use:  
    - **Bucket**: `acs730-huy-terraform-state-2026`  
    - **Region**: `us-east-1`
  - You must **create this bucket** in `us-east-1` *or* update `backend.tf` and any `terraform_remote_state` blocks to use a different bucket name/region.
-
- **SSH key pair** for bastion/instances:
  - Generate a key locally inside Cloud9 (example path one level up):

    ```bash
    ssh-keygen -t rsa -b 4096 -f ../keyname
    ```

  - Import the **public key** into AWS as an EC2 key pair:

    ```bash
    aws ec2 import-key-pair \
      --key-name acs730-key \
      --public-key-material fileb://../keyname.pub
    ```

  - Verify the key pair exists:

    ```bash
    aws ec2 describe-key-pairs --key-names acs730-key
    ```

  - Restrict permissions on the private key so SSH accepts it:

    ```bash
    chmod 400 ~/environment/simple-multi-env-infra-deployment/environments/keyname
    ```

  - Use this key pair name (for example `acs730-key`) as `key_name` in your `terraform.tfvars`.

**Important:** The assignment requires that **remote state** is used and that the code is deployable strictly following this README. If you change the bucket name or region, keep the README in sync.

---

## 3. Configuration

Each environment folder uses a `terraform.tfvars` file to provide values.

### 3.1 nonprod environment (`environments/nonprod/terraform.tfvars`)

Start from `terraform.tfvars.example` and fill in values, for example:

```hcl
aws_region = "us-east-1"

project_name = "acs730-project"
environment  = "nonprod"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

ami_id        = "ami-xxxxxxxx"    # Amazon Linux 2 or similar
instance_type = "t2.micro"
key_name      = "your-ec2-keypair-name"

admin_ip   = "X.X.X.X"         # your public IP /32 for SSH to bastion
owner_name = "Your Full Name"     # used in Apache page
```

Notes:

- **`admin_ip`** should be your public IP in CIDR form to follow **least privilege**.
- **`owner_name`**, **`environment`**, and the instance private IPs are used in the Apache page served by VM1 and VM2 in nonprod.

### 3.2 prod environment (`environments/prod/terraform.tfvars`)

Start from `terraform.tfvars.example` and fill in values, for example:

```hcl
aws_region = "us-east-1"

project_name = "acs730-project"
environment  = "prod"

vpc_cidr = "10.1.0.0/16"

private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

ami_id        = "ami-xxxxxxxx"    # Amazon Linux 2 or similar
instance_type = "t2.micro"
key_name      = "your-ec2-keypair-name"

owner_name = "Your Full Name"
```

Notes:

- There are **no public subnets** in prod.
- EC2 instances in prod do **not** install extra packages (beyond what is necessary).
- The bastion host for connecting into prod lives in the **nonprod VPC**, and its private IP is consumed via `terraform_remote_state` in `prod/main.tf`.

### 3.3 peering environment (`environments/peering/terraform.tfvars`)

Create a new `terraform.tfvars` based on `variables.tf`. For example:

```hcl
aws_region   = "us-east-1"
project_name = "acs730-project"

state_bucket     = "acs730-huy-terraform-state-2026"
nonprod_vpc_cidr = "10.0.0.0/16"
prod_vpc_cidr    = "10.1.0.0/16"
```

Notes:

- **`state_bucket`** must match the S3 bucket used by `backend.tf` in nonprod and prod.
- The **`nonprod_vpc_cidr`** and **`prod_vpc_cidr`** must match the CIDRs used in the corresponding environments.

---

## 4. Deployment Steps

Follow these steps in order.

### 4.1 Create S3 bucket for remote state

If you are using the default bucket name:

1. In the AWS console (or CLI), create an S3 bucket:
   - Name: `acs730-huy-terraform-state-2026`
   - Region: `us-east-1`
   - Block public access as appropriate.
2. Do **not** upload any files; Terraform will manage state files.

If you choose a different bucket name/region:

- Update `environments/nonprod/backend.tf`, `environments/prod/backend.tf`, and the `terraform_remote_state` blocks (for example, in `prod/main.tf` and `environments/peering/main.tf`) to match.
- Make sure this README is updated accordingly.

### 4.2 Deploy nonprod environment

From the repository root inside Cloud9:

```bash
cd terraform_code/environments/nonprod

cp terraform.tfvars.example terraform.tfvars    # if you haven't created it yet
# ...edit terraform.tfvars with your values...

# Get Cloud9 public IP and use it as admin_ip in terraform.tfvars
curl https://ipinfo.io/ip

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This will:

- Create the **nonprod VPC** with public and private subnets, route tables, IGW, NAT GW.
- Create a **bastion host** in a public subnet, accessible only from `admin_ip`.
- Create **VM1 and VM2** in private subnets, install Apache (`httpd`), and serve a custom page that shows:
  - Your name (`owner_name`)
  - Environment (`nonprod`)
  - The instance’s private IP address

### 4.3 Deploy prod environment

```bash
cd ../prod

cp terraform.tfvars.example terraform.tfvars    # if you haven't created it yet
# ...edit terraform.tfvars with your values...

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This will:

- Create the **prod VPC** with private subnets only.
- Create **VM1 and VM2** in private subnets (no extra packages installed).
- Use `terraform_remote_state` to read the bastion private IP from the **nonprod** state for security group rules and routing.

**Note:** nonprod must be deployed first so its remote state exists.

### 4.4 Deploy VPC peering

```bash
cd ../peering

cp terraform.tfvars.example terraform.tfvars    # or create it from scratch as shown above
# ...edit terraform.tfvars with correct state_bucket and VPC CIDRs...

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This will:

- Create a **VPC peering connection** between nonprod and prod.
- Update the **private route tables** in each VPC so that private subnets in nonprod and prod can route traffic to each other.

---

## 5. Verification / How to Test

You should verify the following to match the assignment’s recording requirements:

- **SSH to bastion (nonprod VPC)**:
  - Use the public IP of the bastion host (from AWS console or `terraform output` if defined).
  - From Cloud9, start the SSH agent and add your key:

    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/environment/simple-multi-env-infra-deployment/environments/keyname
    ```

  - Then SSH to the bastion (note the `-A` to enable agent forwarding for later hops):

    ```bash
    ssh -A -i ~/environment/simple-multi-env-infra-deployment/environments/keyname ec2-user@<bastion_public_ip>
    ```

- **SSH from bastion to all VMs**:
  - From the bastion, SSH to the private IPs of:
    - nonprod VM1 and VM2
    - prod VM1 and VM2

- **HTTP to Apache on nonprod VMs**:
  - From the bastion, send HTTP requests to nonprod VM1 and VM2:

    ```bash
    curl http://<nonprod_vm1_private_ip>
    curl http://<nonprod_vm2_private_ip>
    ```

  - Confirm the page shows:
    - Your name
    - Environment name (`nonprod`)
    - The instance’s private IP address

- **Network connectivity between prod and nonprod**:
  - From nonprod VMs or bastion, test connectivity to prod VMs’ private IPs (ping/SSH as allowed by security groups).
  - Be prepared to discuss **pros and cons** of having peering between prod and nonprod.

- **(Optional Bonus) MySQL client**:
  - If implemented, install MySQL client on the bastion in nonprod and configure security groups/routes so it can connect to VM2 in prod on the appropriate port.

All security groups are designed with **principle of least privilege** (limited ports, specific CIDRs).

---

## 6. Cleanup

To avoid unnecessary AWS charges (especially from NAT Gateway), destroy resources when you are done.

**Order matters** (reverse of deployment):

1. **Destroy peering environment**:

   ```bash
   cd terraform_code/environments/peering
   terraform destroy -var-file=terraform.tfvars
   ```

2. **Destroy prod environment**:

   ```bash
   cd ../prod
   terraform destroy -var-file=terraform.tfvars
   ```

3. **Destroy nonprod environment**:

   ```bash
   cd ../nonprod
   terraform destroy -var-file=terraform.tfvars
   ```

4. Optionally, when all infrastructure is destroyed and you no longer need the state:
   - Delete the S3 bucket used for Terraform state (`acs730-huy-terraform-state-2026`), **after** ensuring all `.tfstate` files are no longer needed.

**Important:** Forgetting to destroy the NAT Gateway in nonprod can incur significant cost over time. Always run `terraform destroy` when the assignment is complete.

---

## 7. Notes and Limitations

- The code assumes a specific **region** (default: `us-east-1`) and an S3 bucket name for remote state. If you change either, make sure to update:
  - `backend.tf` in each environment.
  - Any `terraform_remote_state` blocks referencing the bucket.
- If any part of the infrastructure is created manually (for troubleshooting), document that in your assignment submission as required by the instructions.
- This README is written to allow a third party (marker) to deploy and clean up the solution **without additional knowledge** beyond valid AWS credentials and an SSH key.
