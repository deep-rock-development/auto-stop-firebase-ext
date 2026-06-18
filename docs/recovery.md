---
layout: default
title: Recovery
---

# Recovery

Once the extension is up-and-running, the general hope is that you will not have to use it (i.e. you will stay within your budget). However, in the event that it does happen, you will eventually need to restore services - we can call this "recovery".

Recovery means reconnecting the Billing Account the extension removed. It is deliberately simple, but don't skip the first two steps - if you reconnect billing without fixing the underlying problem, the cost blowout simply continues.

## Step 1: Identify how the project cost exceeded your budget

This is project dependent, but generally falls into three categories:

* **Case 1: Organic uptake** in services, meaning you have general growth in activities like more users.
* **Case 2: Technical error** leading to higher than usual uptake in services, this can be a bug in your code (like recursively calling functions).
* **Case 3: Abuse** leading to inorganic uptake in services, which can be a bug in your code (like not authenticating in functions), architectural gaps, missing functionality, misconfiguration, or something else.

The best case scenario is organic uptake as it is generally positive growth. The standard case would be technical error and is within our control and capability. The worst case is abuse which can be much harder to track down, but you can largely mitigate the risk by enforcing Firebase Security Rules and enabling App Check - I suggest reading the [Firebase security checklist](https://firebase.google.com/support/guides/security-checklist) to cover this topic.

Once you have identified the root cause, move on to the next step.

## Step 2: Resolve the root cause issue

Once you have identified *why* the project cost exceeded your budget, you must fix this issue. Unfortunately we cannot provide guidance into how to fix your specific issue.

* Case 1 scenarios are usually non-problematic, however you may consider optimisation of your codebase. Otherwise, there is no inherent issue and you can move on from this step.
* Case 2 scenarios should identify the bug and deploy a fix into your target environment. If you need to reconnect billing to validate the fix, move on to the next step.
* Case 3 scenarios should consult the [Firebase security checklist](https://firebase.google.com/support/guides/security-checklist). When you meet the checklist requirements, or you are comfortable with the risk mitigations, move on to the next step.

## Step 3: Update your budget to a comfortable amount

If we restore services while the project cost still exceeds the budget, the extension will simply re-trigger and will stop services again. Therefore, you must update the budget to be a figure you are comfortable with.

For instance, if a project budget is $100 and the project cost is $100, we must update the budget to be >$100. This is your decision and is highly dependent on which case triggered the cost blowout. In general, we recommend an incremental approach to ensure that bill shock is kept to a minimum.

We recommend that you increase your budget by 5-10% as a starter and gradually increase. For subsequent billing months you should reconsider the budget.

Navigate to [Google Cloud Billing](https://console.cloud.google.com/billing/) > Select your Billing Account > Select Budgets and Alerts on the navigation pane > Select your Budget > update *Target Amount* > Save.

> Once the Billing Account has been connected you can navigate to your budget directly from the Firebase Console. This is helpful when you decide to re-update your budget later. Unfortunately, when you are on Spark Plan and there is no Billing Account, there isn't a clear way to get here from Firebase Console.

## Step 4: Reconnect the Billing Account

From the Firebase Console, there are a couple of ways to reconnect. One approach is under *Usage and Billing* > *Details and Settings* > *Modify Plan*. Here you will be prompted to select your Billing Account and link it.

> **Warning:** Once the Billing Account is reconnected, services will resume. If the underlying problem isn't resolved, then the cost blowout will continue, leading to greater loss.

## Step 5: Continuous monitoring and budget updates

Your Firebase services are now restored! It's good practice to continue monitoring your project in case the underlying issue isn't resolved.

At the end of your billing month, be sure to restore your budget to the original amount!

---

> **Recovering from a 1.x Strategy 2 trigger?** If an older version of the extension disabled APIs in your project, re-enable them under *APIs & Services* in the Cloud Console and redeploy any removed resources (e.g. Cloud Functions). Then update to 2.0.0, which no longer disables APIs.
