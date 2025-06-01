Automatically stop Firebase and Google Cloud services when your project reaches a specified budget threshold.

This extension acts as a financial safety net for your Firebase project by automatically taking action when spending reaches your defined budget limits. When triggered, it can either remove your project's billing account or disable specific services to prevent runaway costs.

**Great for:**

- Teams or solo developers learning Firebase who want to experiment safely
- Proof-of-concept projects
- Projects where cost overruns could be problematic
- Development and staging environments

### Quick Start

1. **Install the extension** from the Firebase Console
2. **Set your stop strategy** during installation
3. **Create a budget** in Google Cloud Console and link it to the extension
4. **Assign IAM permissions** to the extension's service account
5. **Monitor your spending** with peace of mind

### How It Works

The extension monitors your project's spending through Google Cloud Billing budgets. When your spending reaches the configured threshold percentage, a Pub/Sub message triggers the extension. When the extension is triggered, an action (or selected strategy) is invoked. The strategies are:

**Strategy 1: Remove Billing Account (Recommended)**

- **What happens**: Removes the billing account from your project
- **Effect**: All billable services stop running immediately
- **Best for**: Complete cost protection and easy project recovery
- **Recovery**: Manually re-attach the billing account when ready

**Strategy 2: Disable Specific Services**

- **What happens**: Disables predefined Google Cloud APIs/services
- **Effect**: Only specified services stop, others continue running
- **Best for**: Surgical cost control, protecting specific expensive services
- **Recovery**: Re-enable services through Cloud Console or programmatically

Strategy 2 is recommended only for advanced users, as data and resource loss are expected. Additionally recovery can be complex and project specific.

> ⚠️ **Important**: Both strategies will disrupt your application. Plan accordingly and test in non-production environments first.

> ⚠️ **Important**: Google Cloud and Firebase report usage and cost at varying time intervals - this is platform behaviour. Therefore, expect billing information to be delayed and therefore some additional costs above your budget before services are stopped.

### Things you will need

**Pre-installation setup**

You must have a Google Cloud/Firebase project and an associated billing account.

- Decide on a budget amount
- Decide on a stop strategy (Strategy 1 or Strategy 2)

**Post-installation setup**

After the installation of this extension, you must:

- Create a Budget against your project (if none exists), and connect it to the Pub/Sub topic created
- Assign the extension's service account the `roles/billing.projectManager` role (for Strategy 1)
- Assign the extension's service account the `roles/serviceusage.service` role (for Strategy 2)

> 💡 Due to Firebase Extensions limitations, you must manually setup the budget and IAM role assignment. In future, where limitations are removed, this extension will be updated.

### Services used

This extension uses the following Firebase services which may have associated charges:

- Cloud Functions (Firebase functions)
- Cloud Billing
- Cloud Service Usage
- Cloud Pub/Sub
- If you enable events [Eventarc fees apply](https://cloud.google.com/eventarc/pricing).

This extension does not use any third-party services.

### Billing

To install an extension, your project must be on the [Blaze (pay as you go) plan](https://firebase.google.com/pricing)

- You will be charged a small amount (typically around $0.01/month) for the Firebase resources required by this extension (even if it is not used).
- This extension uses other Firebase and Google Cloud Platform services, which have associated charges if you exceed the service’s no-cost tier:
- Cloud Functions (Node.js 10+ runtime. [See FAQs](https://firebase.google.com/support/faq#extensions-pricing))

### Need Help?

This extension is open source and welcomes contributions:

- ➡️ **Repository**: [GitHub Repository](https://github.com/deep-rock-development/auto-stop-firebase-ext)
- 🐛 **Bug reports**: [File an issue](https://github.com/deep-rock-development/auto-stop-firebase-ext/issues)
- 📖 **Documentation**: [Auto Stop Extension Documentation](https://deep-rock.gitbook.io/auto-stop-services)
