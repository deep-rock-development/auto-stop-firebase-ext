# Auto Stop Services Firebase Extension

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/keston)

## What is this?

This extension is intended to support development, or early stage production environments from accruing significant costs by stopping services. This is a challenge as cloud platforms are usage based, and many methods provided by cloud providers are intended to support service uptime; and will not make any effort to mitigate unintended service overuse. Billing alerts are out of the box only intended to alert administrators that a budget threshold has been reached, but not take any action.

See also: [Auto Stop Services](https://deep-rock.gitbook.io/auto-stop-services) on GitBook.

## How does it work?

![High Level View of Extension](high-level-view-diagram.png)
This Firebase extension monitors the associated budget and removes the billing account from the project when a specified budget threshold is reached.

### Removing the Billing Account from Project

When a billing account is removed from a project:

- **Service Suspension**: All paid services within the project are immediately suspended. This includes VM instances, databases, and other cloud services that incur costs.
- **Access to Resources**: You can still access and view resources in the Google Cloud Console, but you cannot create new resources or use services that require billing.
- **Data Persistence**: Data stored in services like Cloud Storage, Firestore, and databases is preserved but may become inaccessible until billing is re-enabled.
- **Project Functionality**: Essential Google Cloud services, including IAM and Google Cloud Console access, remain available for managing project settings and restoring billing.
- **Billing Charges**: Any pending charges accrued before the billing account was removed will still be billed. No new charges will be generated until billing is re-established.

This strategy prevents additional costs from accruing but has an immediate impact on service availability.

> ℹ️ **Note**: Earlier versions (1.x) offered a second strategy that disabled selected service APIs. This was removed in 2.0.0 because Google's Service Usage API no longer allows disabling a service that has existing resources (see the [CHANGELOG](CHANGELOG.md) for details and the [Google documentation reference](https://docs.cloud.google.com/service-usage/docs/hierarchical-service-activation/manage-enablement)).

## Installation Configuration

![Extension Level View](extension-context-diagram.png)
During the extension installation, you will be asked to configure it with the following parameters:

- `TOPIC_NAME` defines the name of the pub/sub topic. A billing alert is published here, which will trigger the auto-stop (if the threshold is reached).
- `BUDGET_STOP_THRESHOLD_PERCENT` defines the percentage (0.0-1.0) of the budget that will trigger the stop strategy, default is 1.0 (100%)
- `DISABLE_BILLING` enables removal of the billing account (requires `project billing manager` role), defaults to true
- `LOCATION` defines the deployment location for the cloud function, defaults to use-central1

## Manual Steps After Installation

After installing the extension, you must:

1. **Set Up a Budget**

   - **Firebase**: Go to Settings > Usage & Billing. Set a budget and note its name.
   - **GCP**: Navigate to Billing > Budgets. Create a new budget, set it, and note the budget name.

2. **Connect the Budget to a Predefined Topic**

   - Link the budget to the topic specified when installed the extension: `{TOPIC_NAME}`.

3. **Update the Service Account Permissions**
   - Grant the following IAM role to `{EXTENSION_NAME}@{PROJECT_ID}.iam.gserviceaccount.com`:
     - Project Billing Manager (`roles/billing.projectManager`) to manage project billing settings.

## Example Pub/Sub Message

When a budget alert fires, the message content will look like the below:

```json
{
  "budgetDisplayName": "Your Budget Name",
  "alertThresholdExceeded": 0.5,
  "costAmount": 500.0,
  "costIntervalStart": "2021-01-01T00:00:00Z",
  "budgetAmount": 1000.0,
  "budgetAmountType": "SPECIFIED_AMOUNT",
  "currencyCode": "USD",
  "schemaVersion": "1.0",
  "notificationType": "ACTUAL",
  "projectId": "your-project-id",
  "billingAccountId": "012345-6789AB-CDEF01"
}
```

The key element of this message is the `alertThresholdExceeded`, all other information is effectively discarded.

## Testing this Extension

Once you have followed the steps, you can submit a message through the pub/sub topic. Any results will be published as logs, which you can monitor.

This example message will not execute any strategy.

```json
{
  "extensionTest": true
}
```
