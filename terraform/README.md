# Terraform for Citizen

Contains the Terraform code required to do storage for Citizen

## Resources created and credentials required

In order for this terraform module to work, it needs the following

- AWS Account with the following permissions
  - Create IAM User
  - Create IAM Policy
  - Attach IAM Policy to User
  - Create S3 bucket
- Kubectl access to a cluster, with permission to create secrets
- Helm access to a cluster, with standard permissions for deployments and services

## Variables

| Name     | Description                                            |
| -------- | ------------------------------------------------------ |
| `prefix` | A prefix added to every name of every resource created |
