# Full Stack App with Infrastructure Deployment

## 🏠 Project Overview

A simple full-stack application with a front-end landing page, a backend API, and a database, deployed using ECS with Terraform.

## 🚀 Architecture

- **Frontend:** VueJS + Vite
- **Backend:** NodeJS + Express
- **Database:** PostgreSQL
- **Infrastructure:** Terraform for ECS

The UI runs on port 80, and the backend runs on port 3000, both behind the same load balancer. The project is still a prototype, tests, CI improvements, and better error handling can be added in the future.

## Important References to other Readmes

Please, for more details see also:

- frontend/README.md
- backend/README.md
- infrastructure/README.md

## 🛠️ Some To Do tasks

- Unit tests

- Linting (for JS/TS and Terraform)

- CI cache (npm, Docker, Terraform plugins)

- CICD: separate into different jobs and build only if there are changes. E.g. if UI does not have changes, don't build nor push anything.

- Terraform security checks (tfsec, tflint)

- CI formatting check (terraform fmt)

- Terraform modules for ECS

- ECR can be built separately (similar to Secrets)

- Full documentation and architecture diagram

- Use DB tracking tool like Liquibase or Flyway for SQL scripts

- Unharcode region

- Unharcode /api on Frontend

- Automate the bootstrap stack to avoid multiple steps on creation

## Deploying to AWS (Terraform)

```
# Build Secret
cd infrastructure/envs/secret
terraform init
terraform apply

# Build Backend Stack
cd infrastructure/envs/dev
terraform init
terraform apply
```

## Project structure:

├── frontend
│ └── VueJS app
├── backend
│ └── NodeJS + Express app
├── database
├── infrastructure
│ └── modules
│ └── envs
│ └──── dev
│ └──── secrets
