# Packer Swarm AMI

This project uses HashiCorp Packer to create a custom Amazon Machine Image (AMI) based on the Amazon Linux 2 AMI with specific enhancements tailored to streamline the deployment process of Docker Swarm stack files. The custom AMI is configured with Docker pre-installed and includes a cron job that monitors a Docker Swarm stack repository for automated deployments. To utilize this custom AMI effectively, users can reference the [terraform-swarm-aws] repository.

## Useful Commands

```shell
# Initialize Packer
packer init -upgrade template.pkr.hcl

# Check template format
packer fmt -check -diff -write=false -recursive template.pkr.hcl

# Format template
packer fmt -recursive -diff template.pkr.hcl

# Validate syntax and configuration
packer validate template.pkr.hcl

# Build the custom AMI
packer build template.pkr.hcl
```

## Pipeline Variables

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
