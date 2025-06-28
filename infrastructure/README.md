# Infrastructure - Terraform (AWS)

## Deploy

# Bootstrap Infrastructure

**Prerequisite:** Ensure the remote-state S3 bucket exists before running Terraform, check the following example:

```bash
aws s3api create-bucket \
  --bucket terraform-remote-state-svillarreal \
  --region us-east-1
```

In `backend.tf`, reference the bucket directly:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-svillarreal"
    key    = "devex-fullstack-challenge/secrets.tfstate"
    region = "us-east-1"
  }
}
```

Secondly, you need to deploy bootstrap stack, since Aurora RDS depends on it. After creating it, use AWS Console or CLI to configure the secret value. After that, go ahead an create the required environment (for example, dev). It will also create the ECR repos for the backend and frontend. Then CICD pipeline updates the repos to point to the correct images. On the other hand, AWS Secrets in Secrets Manager with DB username and password must be created, along with DB info. Check the following example (once the main stack is deployed, remember to update the secret host):

```json
{
  "username": "devexchsvc_admin",
  "password": "...",
  "host": "initially empty, fill later after stack creation",
  "port": "5432",
  "database": "devexchsvc_db_dev"
}
```

### GitHub Actions: Required Variables

After running `terraform apply` for the first time, set the following variables in **GitHub → Settings → Environments → DEV**:

| Name        | Description      | Example |
| ----------- | ---------------- | ------- |
| Environment | Environment name | DEV     |

| ECR_BACKEND_REPOSITORY_NAME
| Name of the ECR repo for backend Docker images | devexchsvc-ecr-backend-repo-dev |
| ECR_FRONTEND_REPOSITORY_NAME | Name of the ECR repo for backend Docker images | devexchsvc-ecr-frontend-repo-dev |
| ROLE_TO_ASSUME | IAM role ARN to assume from GitHub Actions | arn:aws:iam::123456789012:role/github-actions-role-dev |

## Requirements

- After the stack is created (and AWS secret is configured), make sure to run the sql script (suggested to use CloudShell) located on `../../../database/20250627_db_init.sql`
- IP range available: 10.1.0.0/16

## TODO

- Implement modules for ECS stuff and RDS
- Use custom KMS for Secret and RDS instead of AWS Managed
- Add secret rotation
- Secure tfstate since it will contain the DB secret value
- Add tags

```

```
