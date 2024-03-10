# After Installation

## Next Steps

1. **Configure Your Budget Alert** to publish messages to the Pub/Sub topic (`{TOPIC_NAME}`) used by this extension.

2. **Verify IAM Permissions**:

   - Ensure the extension's service account (`{EXTENSION_NAME}@{PROJECT_ID}.iam.gserviceaccount.com`) has the necessary roles:
     - For Strategy 1: Project Billing Manager (`roles/billing.projectManager`)
     - For Strategy 2: Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)

3. **Test the Extension** by publishing a test message to your Pub/Sub topic. Monitor the logs for any actions taken by the extension in response. You can submit a message to the pub/sub topic with the content `{"extensionTest": true}` to verify permissions and log the output (this will not execute the strategy).

## Manual Intervention

- **Review and Confirm Service Account Permissions**. Double-check the roles assigned to the extension's service account to ensure it can perform its tasks.

- **Monitor Your Costs**. Even with this extension, monitor your Google Cloud costs and usage through the Google Cloud Console.

## Uninstalling the Extension

If you decide to uninstall this extension, remember to:

- Remove any budget alerts configured to publish to the extension's Pub/Sub topic.
- Optionally, clean up any resources created by the extension that are no longer needed.

## Getting Help

For issues or questions about this extension, check the [GitHub repository](https://github.com/deep-rock-development/auto-stop-firebase-ext) or reach out through Firebase support.

Remember, disabling essential services can impact your application's functionality. Plan and test carefully.
