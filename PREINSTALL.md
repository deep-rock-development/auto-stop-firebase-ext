Use this extension to stop Firebase and Google Cloud Services when a specified budget threshold is reached in your project.

This extension supports the following use cases:

- Stop your project from accuring more costs than you intend.
- Disable predefined services when costs ramp up unexpectedly.
- Control the costs of your project and rest easy knowing you will not have any unexpected bills.
- Kill switch your non-production environment services.

The extension delivers on these use cases by:

- **Strategy 1:** Removing the billing account from your project through the Billing API, thereby stopping all services from running (Recommended)
- **Strategy 2:** Disabling predefined Google Cloud Services in your project through the Service Usage API.

### Things you will need

The extension is intended to do as much of the setup work as possible for you. However, due to some limitations with extensions, some manual steps are required.

#### Pre-installation setup

You must have a Google Cloud/Firebase project and an associated billing account.

- Decide on a budget amount
- Decide on a stop strategy (Strategy 1 or Strategy 2)

#### Post-installation setup

After the installation of this extension, you must:

- Create a Budget against your project (if none exists), and connect it to the Pub/Sub topic created
- Assign the extension's service account the `roles/billing.projectManager` role (for Strategy 1)
- Assign the extension's service account the `roles/serviceusage.service` role (for Strategy 2)

### Services used

This extension uses the following Firebase services which may have associated charges:

- Cloud Functions (Firebase functions)
- Cloud Billing
- Cloud Service Usage
- Cloud Pub/Sub
- If you enable events [Eventarc fees apply](https://cloud.google.com/eventarc/pricing).

This extension does not use any third-party services.

#### A further note

Unfortunately due to Firebase Extensions limitations, there are specific activities that are not supported. One of which is the creation of a budget. This is true as at 13th July 2024. However, this extension has been created to minimise the amount of work that is required. In future, where limitations are removed, this extension will be updated.

However the repository is active, and any proposed changes are welcome!

### Billing

To install an extension, your project must be on the [Blaze (pay as you go) plan](https://firebase.google.com/pricing)

- You will be charged a small amount (typically around $0.01/month) for the Firebase resources required by this extension (even if it is not used).
- This extension uses other Firebase and Google Cloud Platform services, which have associated charges if you exceed the service’s no-cost tier:
- Cloud Functions (Node.js 10+ runtime. [See FAQs](https://firebase.google.com/support/faq#extensions-pricing))
