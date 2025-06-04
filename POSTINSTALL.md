For help with installing or using this extension, you can go to the [Auto Stop Extension Documentation](https://deep-rock.gitbook.io/auto-stop-services).

> 💡 Due to Firebase Extensions limitations, you must manually setup the budget and IAM role assignment. In future, where limitations are removed, this extension will be updated.

### Post-installation steps

After the installation of this extension, you must:

- Create a Budget against your project (if none exists), and connect it to the Pub/Sub topic created
- Assign the extension's service account the `roles/billing.projectManager` role (for Strategy 1)
- Assign the extension's service account the `roles/serviceusage.serviceUsageAdmin` role (for Strategy 2)

Further detail is provided below.

### Detailed post-installation steps

This extension requires the following post-installation steps:

1. Create a budget if none exists:
   - **Firebase**: Go to Settings > Usage & Billing. Set a budget.
   - **GCP**: Navigate to Billing > Budgets. Create a new budget.
2. Click the 'View budgets' button, select your budget, and ensure that there is an alert threshold at 100%.
3. Edit the Budget to connect it to the Pub/Sub topic created by the extension, this is the `TOPIC_NAME` you set. The setting is 'Connect a Pub/Sub topic to this budget' when editing.
4. Under the IAM service in GCP, assign the extension's service account (`ext-functions-auto-stop-billing@{PROJECT_ID}.iam.gserviceaccount.com`) the relevant IAM roles:
   - **Strategy 1**: Project Billing Manager (`roles/billing.projectManager`)
   - **Strategy 2**: Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)

### How it all works

Once all the post-installation steps are completed, the Pub/Sub topic we setup will listen to the budget for an alert. When an alert is raised that meets (or exceeds) the defined threshold a Firebase function will execute the strategy you select.

There are three key components to this extension:

- Budget - will monitor your costs and raise an alert at pre-defined thresholds.
- Pub/Sub topic - will receive any alerts raised and provide them to subscribers.
- Firebase function - will receive alerts, assess, and take appropriate action (dismiss or stop services)

The budget will generate messages and send them to the topic, these messages are structured as:

```json
{
  "budgetDisplayName": "Your Budget Name",
  "alertThresholdExceeded": 0.5,
  "costAmount": 500.0,
  "projectId": "your-project-id",
  "billingAccountId": "012345-6789AB-CDEF01"
}
```

The field `alertThresholdExceeded` is monitored by the extension, and will determine whether or not to take action. Where the value of this field meets or exceeds the parameter `BUDGET_STOP_THRESHOLD_PERCENT` then the strategy is executed. If this field is not present, the extension will not take action.

### Testing permissions

The easiest way to test this extension is to publish a test message into the topic `TOPIC_NAME`. You can use the test message with the content:

```
{
  "extensionTest" : true
}
```

This will validate that the extension has the necessary permissions to execute the service stop. You can monitor Logs Explorer to see the results.

### Additional Notes

This extension is aimed at supporting Firebase users to prevent cost-overrun. There are some additional points to keep in mind when using this extension:

- Review and confirm Service Account permissions includes the roles assigned to the extension's service account are sufficient to perform its tasks.
- Even with this extension, you should monitor your Google Cloud costs and usage through the Google Cloud Console.
- Please consider capturing your configuration through your code repository (versus click ops).

> ⚠️ **Important**: Both strategies will disrupt your application. Plan accordingly and test in non-production environments first.

> ⚠️ **Important**: Google Cloud and Firebase report usage and cost at varying time intervals - this is platform behaviour. Therefore, expect billing information to be delayed and therefore some additional costs above your budget before services are stopped.

### Need Help?

This extension is open source and welcomes contributions:

- ➡️ **Repository**: [GitHub Repository](https://github.com/deep-rock-development/auto-stop-firebase-ext)
- 🐛 **Bug reports**: [File an issue](https://github.com/deep-rock-development/auto-stop-firebase-ext/issues)
- 📖 **Documentation**: [Auto Stop Extension Documentation](https://deep-rock.gitbook.io/auto-stop-services)
