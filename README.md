# Infrastructure as Code (IaC) Repository

This repository is exclusively responsible for provisioning and managing the cloud infrastructure used by the machine learning platform.

All AWS resources are defined declaratively using Terraform, allowing the entire environment to be version-controlled, reproducible, and easily maintainable.

The repository serves as the foundation for all other services, including:

* Airflow
* Feature Engineering
* Model Training
* MLflow

---

# Repository Purpose

The IaC repository is responsible for creating and managing:

* Amazon ECS Clusters
* Amazon ECR Repositories
* Amazon S3 Buckets
* IAM Roles and Policies
* VPC Networking
* Public and Private Subnets
* Security Groups
* Application Load Balancers (ALB)
* ECS Task Definitions
* CloudWatch Logging
* OIDC Integration with GitHub Actions

All infrastructure changes should be performed through Terraform rather than manually through the AWS Console.

---

# `main` Branch — Production Infrastructure

The `main` branch contains the production-ready infrastructure configuration.

Changes merged into this branch are intended to be deployed to AWS production environments.

This branch manages infrastructure for:

* Airflow orchestration
* Feature engineering workloads
* Model training workloads
* MLflow tracking services

---

# CI/CD Pipeline

The CI/CD pipeline for `main` performs the following steps:

1. Validate Terraform configuration
2. Initialize Terraform
3. Generate an execution plan
4. Apply infrastructure changes
5. Update AWS resources

Authentication is performed using AWS OIDC integration.

## Required GitHub Secrets / Variables

```text
AWS_REGION
AWS_ARN_ROLE
```

### Description

* `AWS_REGION`: AWS region where infrastructure is deployed.
* `AWS_ARN_ROLE`: IAM role assumed by GitHub Actions through OIDC.

---

# Managed AWS Resources

The repository provisions and manages resources such as:

## Compute

* Amazon ECS Clusters
* ECS Services
* ECS Task Definitions

## Container Registry

* Amazon ECR Repositories

## Storage

* Amazon S3 Buckets

## Networking

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* Route Tables
* Security Groups
* Application Load Balancers

## Security

* IAM Roles
* IAM Policies
* OIDC Providers

## Monitoring

* CloudWatch Log Groups
* ECS Logging Configuration

---

# Relationship with Other Repositories

This repository provides the infrastructure required by:

| Repository          | Purpose                                     |
| ------------------- | ------------------------------------------- |
| Airflow             | Workflow orchestration                      |
| Feature Engineering | Data preprocessing and transformation       |
| Model Training      | Model training and experimentation          |
| MLflow              | Experiment tracking and artifact management |

Application repositories consume resources created by this repository but do not manage the infrastructure themselves.

---

# Notes

* This repository is the single source of truth for cloud infrastructure.
* Infrastructure changes should always be made through Terraform.
* Manual modifications in the AWS Console may be overwritten by future Terraform deployments.
* Application repositories are responsible for building and deploying containers, while this repository is responsible for creating and maintaining the underlying AWS resources.
* All production infrastructure should be provisioned and updated through the CI/CD pipeline whenever possible.
