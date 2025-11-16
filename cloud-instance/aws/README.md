# AWS Cloud Instance Infrastructure

Terraform configuration for creating an AWS EC2 instance with an attached EBS volume.

## TLDR

Quick launch with memory-optimized spot instance:

```bash
terraform init
terraform apply -var="instance_type=r5.xlarge" -var="use_spot_instance=true"
```

**Why r5.xlarge?** Memory-optimized instances (r5 family) provide better value for memory-intensive workloads: 32GB RAM for ~$0.008/GB vs m5's ~$0.012/GB. As a spot instance, this gives you 32GB RAM for up to 90% off (~$18/month vs $184/month on-demand).

For GPU (ML/AI workloads):

```bash
# G4dn with NVIDIA T4 GPU - spot ~$0.16/hr (~$117/mo) vs on-demand $0.526/hr
terraform apply -var="instance_type=g4dn.xlarge" -var="use_spot_instance=true"
```

## Features

- **EC2 Instance**: Ubuntu LTS (24.04) instance
- **EBS Volume**: 30GB volume (protected from accidental deletion)
- **Security Group**: Opens ports 3000, 8000, and 8080
- **SSM Access**: Connect via AWS Systems Manager Session Manager (no SSH keys needed)
- **Auto-mounting**: EBS volume automatically mounted at `/mnt/data`
- **Auto-termination**: Instance automatically terminates after 1 hour 50 minutes (configurable)
- **Pre-installed Tools**: vim, Python 3, build tools (gcc, g++, make), clang, CUDA toolkit

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed (>= 1.0)
3. Session Manager plugin for AWS CLI (for connecting to the instance)

Install Session Manager plugin:
```bash
# For Ubuntu/Debian
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. Connect to the instance using SSM:
```bash
# The exact command will be in the terraform outputs
aws ssm start-session --target <instance-id> --region <region>
```

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize as needed:
- `aws_region`: AWS region (default: us-east-2 - Ohio, cheapest region)
- `availability_zone`: AZ for resources (default: us-east-2a)
- `instance_name`: Name tag for the instance
- `instance_type`: EC2 instance type (default: t3.micro)
- `ebs_volume_size`: Size of EBS volume in GB (default: 30)
- `auto_shutdown_minutes`: Auto-terminate after N minutes (default: 110, set to 0 to disable)

## Outputs

After applying, you'll see:
- `instance_id`: EC2 instance ID
- `instance_public_ip`: Public IP address
- `ebs_volume_id`: EBS volume ID
- `ssm_connection_command`: Command to connect via SSM

## EBS Volume Protection

The EBS volume has `prevent_destroy` enabled. To destroy it:
1. Remove the lifecycle block from `main.tf`
2. Run `terraform destroy`
