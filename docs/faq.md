---
layout: default
title: FAQ
---

# FAQ

## Is there a delay for the extension to trigger?

The short answer is that there could be. This extension, and pretty much any approach using Cloud Billing, is at the mercy of Google Cloud. If there is a delay in Google Cloud calculating billing, then naturally this will mean the extension will trigger later than what is ideal. However, in my experience, this has not been a big issue.

An excerpt from the [Firebase documentation](https://firebase.google.com/docs/projects/billing/avoid-surprise-bills) around this:

> Depending on the Google Cloud or Firebase service, sometimes there's a slight delay (up to a few days) in usage reporting to Cloud Billing.

## What do I do once the extension is triggered?

When the extension is triggered, it removes the Billing Account from your Firebase project, freezing all paid services. To restore them, see the detailed guide on the [Recovery](recovery.html) page.

## Why am I getting logs from this extension?

Logs are generated when the extension receives an alert from Google Cloud Billing via Budgets. At the time of writing, any alert received is logged by the extension.

Alerts are also generated periodically by GCP, even if a threshold hasn't been met. This is OK behaviour as this extension only responds to configured thresholds being met or exceeded.

Excerpt below from the [GCP documentation](https://cloud.google.com/billing/docs/how-to/budgets-programmatic-notifications):

> Budget notifications are sent to the Pub/Sub topic multiple times per day with the current status of your budget.

We do not expect high volumes of logs. However you can filter these out in your log queries.

## What happened to Strategy 2 (disabling APIs)?

It was removed in version 2.0.0. Google's Service Usage API no longer allows disabling a service that still has resources in it, and there is no way to force it. Billing account removal was always the recommended strategy and is now the only one. The full reasoning, with references to Google's documentation, is in the [CHANGELOG](https://github.com/deep-rock-development/auto-stop-firebase-ext/blob/main/CHANGELOG.md).

If you are on 1.x with `DISABLE_BILLING` set to No, note that after updating to 2.0.0 you must set it to Yes - otherwise the extension takes no action on budget alerts.

## What can I do if I find an issue or have questions?

Feel free to raise an issue or questions in the [GitHub repository](https://github.com/deep-rock-development/auto-stop-firebase-ext). It is an open source extension, and you are more than welcome to submit pull requests / code changes.

We periodically update the extension to be up-to-date with Firebase, and in conjunction with user feedback. We also update this guide. So any requests, issues, or questions are welcome.
