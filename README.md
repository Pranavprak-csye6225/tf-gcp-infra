# Terraform Infrastructure for Google Cloud Platform

This repository contains Terraform configurations to set up networking infrastructure on Google Cloud Platform (GCP).

## Prerequisites

Before you begin, ensure you have the following:

- [Google Cloud SDK (gcloud CLI)](https://cloud.google.com/sdk/docs/install) installed and configured.
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed on your local machine.
- Permissions to create resources in a GCP project.

## Setup Instructions

Follow these steps to set up your infrastructure using Terraform:

1. **Enable GCP Service APIs**: Before you can use GCP services, you need to enable the required APIs for your project. Follow the instructions in the [Enable GCP Service APIs](#enable-gcp-service-apis) section to enable the necessary APIs.

2. **Initialize Terraform**: Navigate to the cloned repository directory and initialize Terraform.

   ```bash
   terraform init
   ```

3. **Review Terraform Plan**: Generate and review the Terraform plan to ensure that the changes align with your expectations.

   ```bash
   terraform plan
   ```

4. **Apply Terraform Changes**: Apply the Terraform changes to create the networking infrastructure on GCP.

   ```bash
   terraform apply
   ```

5. **Verify Infrastructure**: Once the Terraform apply completes successfully, verify that the networking infrastructure is set up correctly in the GCP Console.

6. **Destroy Infrastructure (Optional)**: If you want to tear down the infrastructure, use Terraform to destroy it.

   ```bash
   terraform destroy
   ```

## Enable GCP Service APIs

Before you can start using Google Cloud Platform (GCP) services, you need to enable the required APIs. Follow these steps to enable the necessary services for your project:

1. Open the Google Cloud Console.
2. Select your project from the project dropdown menu at the top of the page.
3. Navigate to the "APIs & Services" > "Library" page.
4. Search for the required services and click on them to enable.
5. Once enabled, it may take 10-15 minutes for the services to become fully functional.

## Enabled Google APIs List

Document the list of enabled Google APIs for your project here.

1. Google Cloud Compute Engine API

