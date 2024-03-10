# Before You Install

## Understand the Extension

This extension helps prevent unintended costs by stopping services when a specified budget threshold is reached. It offers two strategies:

1. Removing the billing account from the project.
2. Disabling predefined Google Cloud services.

## Prerequisites

- A Google Cloud project with Firebase enabled.
- Billing set up on your Google Cloud project.
- The [Pub/Sub API](https://cloud.google.com/pubsub) enabled.
- Familiarity with IAM roles, particularly:
  - Project Billing Manager (`roles/billing.projectManager`)
  - Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)

## Pre-installation Steps

1. **Set a Budget** in Google Cloud Billing.
2. **Note the Budget Name**; you'll need it for the extension configuration.
3. **Decide on the Stop Strategy** you intend to use.

Make sure you have the necessary permissions to assign IAM roles to service accounts.

## Prepare Your Environment

- Ensure the service account running this extension has the `Pub/Sub Editor`, `Service Usage Admin`, and `Project Billing Manager` roles, as it will need to create topics, and potentially disable billing or services.
- Determine the Pub/Sub topic name you will use to trigger this extension.
