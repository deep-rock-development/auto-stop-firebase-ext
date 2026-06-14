---
layout: default
title: Installation
---

# Installation

Setup takes about ten minutes. There are seven steps: install the extension, put the project on Blaze, configure it, verify it, create a budget, connect the budget to the topic, and grant one IAM role.

## 1. Install from the Extensions Hub

Open the [extension page](https://extensions.dev/extensions/kurtweston/functions-auto-stop-billing) and choose **Install in Firebase console**.

<video src="assets/install/CleanShot_2025-02-26_at_16.45.14.mp4" poster="assets/install/CleanShot_2025-02-26_at_16.45.14.jpg" autoplay loop muted playsinline></video>

## 2. Put the project on the Blaze plan

Extensions require the Blaze (pay-as-you-go) plan. If your project isn't on Blaze, you'll be prompted to upgrade during installation.

<video src="assets/install/CleanShot_2025-02-26_at_16.47.49.mp4" poster="assets/install/CleanShot_2025-02-26_at_16.47.49.jpg" autoplay loop muted playsinline></video>

## 3. Configure the extension

Review the APIs the extension enables and set its parameters. The defaults are fine for most projects, see the [parameter table](#configuration-parameters) below.

<video src="assets/install/CleanShot_2025-02-26_at_17.10.08.mp4" poster="assets/install/CleanShot_2025-02-26_at_17.10.08.jpg" autoplay loop muted playsinline></video>

## 4. Verify the installation

Confirm the extension installed with no errors, and that two functions were created: `onInstallExtension` and `stopTriggered`.

<video src="assets/install/CleanShot_2025-02-26_at_20.13.25.mp4" poster="assets/install/CleanShot_2025-02-26_at_20.13.25.jpg" autoplay loop muted playsinline></video>

<video src="assets/install/CleanShot_2025-02-26_at_17.24.19.mp4" poster="assets/install/CleanShot_2025-02-26_at_17.24.19.jpg" autoplay loop muted playsinline></video>

## 5. Create a budget

Create a billing budget in the Firebase Console (Settings > Usage & Billing) or in Google Cloud (Billing > Budgets and alerts). Make sure there's an alert threshold at 100%.

<video src="assets/install/CleanShot_2025-02-26_at_20.30.42.mp4" poster="assets/install/CleanShot_2025-02-26_at_20.30.42.jpg" autoplay loop muted playsinline></video>

## 6. Connect the budget to the Pub/Sub topic

Edit the budget and connect it to the extension's topic under **Connect a Pub/Sub topic to this budget**. The topic name is whatever you set `TOPIC_NAME` to (default: `ext-firebase-trigger-auto-stop`).

## 7. Grant the IAM role

Assign the extension's service account the **Project Billing Manager** role (`roles/billing.projectManager`), either in the IAM console, or in one command:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:ext-functions-auto-stop-billing@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/billing.projectManager"
```

> Due to Firebase Extensions limitations, the budget and IAM role assignment must be done manually, extensions cannot request billing roles themselves.

## Configuration parameters

| Parameter | Purpose | Default |
|-----------|---------|---------|
| `TOPIC_NAME` | Pub/Sub topic the budget publishes alerts to | `ext-firebase-trigger-auto-stop` |
| `BUDGET_STOP_THRESHOLD_PERCENT` | Budget percentage (0.0-1.0) that triggers the stop | `1.0` |
| `DISABLE_BILLING` | Remove the billing account when the threshold is reached | `Yes` |
| `LOCATION` | Cloud Functions deployment region | `us-central1` |

> **Warning:** `DISABLE_BILLING` set to No means the extension takes no action on budget alerts. As of 2.0.0 billing removal is the only stop strategy, so leave this on Yes.

## Testing

Publish a test message to the topic to verify permissions are set up correctly:

```json
{
  "extensionTest": true
}
```

The extension checks its IAM permissions and logs the result, look for the output under the `stopTriggered` function in Logs Explorer. A "Permission not granted" line means you should revisit step 7.
