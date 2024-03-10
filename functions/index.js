// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";
import { initializeApp } from "firebase-admin/app";
import { getExtensions } from "firebase-admin/extensions";
import { createTopic } from "./pubsub.js";
import { disableService } from "./service-usage.js";
import * as Constants from "./constants.js";
import { disableBillingForProject } from "./budget.js";
import { testIamPermissions } from "./resource-validation.js";

//------------------------------------------------//

// Initialize the Firebase Admin SDK
initializeApp();

/** Extension lifecycle - triggered onInstall */
export const onInstallExtension = functions.tasks
  .taskQueue()
  .onDispatch(async () => {
    await installExtension();
  });

export const onUpdateExtension = functions.tasks
  .taskQueue()
  .onDispatch(async () => {
    await installExtension();
  });

/** Trigger from Pub/Sub topic, which in turn will switch services off. */
export const stopTriggered = functions.pubsub
  .topic(process.env.TOPIC_NAME)
  .onPublish(async (message) => {
    // stopServices(); //async?
    console.log("ℹ️ Received budget alert message...");
    await stopServices(message);
  });

//------------------------------------------------//

export const installExtension = async () => {
  getExtensions().runtime().setProcessingState("NONE");
  try {
    console.log("⚙️ Installing extension...");
    const projectId = process.env.GCLOUD_PROJECT;
    const topicName = process.env.TOPIC_NAME;
    const stopThreshold = process.env.BUDGET_STOP_THRESHOLD_PERCENT;

    console.log("⚙️ Creating topic...");
    await createTopic(topicName);

    // const billingAccountId = await getBillingAccountId(projectId);
    // const budget = await findBudgetByName(billingAccountId, budgetName);
    // console.log(`Found Budget: ${budget}`);
    getExtensions().runtime().setProcessingState("PROCESSING_COMPLETE");
    console.log("✅ Extension installed successfully");
    return;
  } catch (error) {
    console.error(`❌ Failed to install extension:`, error);
    getExtensions().runtime().setProcessingState("PROCESSING_FAILED");
    throw error;
  }
};

export const stopServices = async (message) => {
  const messageData = message.data
    ? Buffer.from(message.data, "base64").toString()
    : null;

  // Parse the message data as JSON
  const data = messageData ? JSON.parse(messageData) : null;
  console.log(
    `🚨 ${data.alertThresholdExceeded} : ${process.env.BUDGET_STOP_THRESHOLD_PERCENT}`
  );

  if (data.extensionTest) {
    console.log("ℹ️ Received budget alert message with test parameter");
    await testIamPermissions(process.env.GCLOUD_PROJECT);
    return;
  }

  if (!data.alertThresholdExceeded) {
    console.log("🚨 Alert raised, but there was no budget data in the payload");
    return;
  }

  if (!process.env.BUDGET_STOP_THRESHOLD_PERCENT) {
    console.log("🚨 Alert raised, but there was no budget threshold set");
    return;
  }

  // Check if the alert threshold has been exceeded
  if (data.alertThresholdExceeded < process.env.BUDGET_STOP_THRESHOLD_PERCENT) {
    console.log("✅ Budget below threshold, services are online");
    return;
  }

  console.log("⛔ Budget threshold has been reached, shutting down services");

  await executeDisable();
};

export const executeDisable = async () => {
  await executeDisableBilling();
  await executeDisableAPI();
};

export const executeDisableAPI = async () => {
  //Extract selected APIs
  const disableApiList = process.env.DISABLE_API_LIST.split(",");
  let disableFunctions = false;
  console.log(`ℹ️ List of services to disable: ${disableApiList}`);

  if (disableApiList.length === 0) {
    console.log("ℹ️ No services to disable");
    return;
  }

  //Iterate through selected APIs and disable one-by-one
  for (const api of disableApiList) {
    //We need to disable cloud functions last
    if (api === Constants.SERVICE_CLOUDFUNCTIONS) {
      disableFunctions = true;
    } else {
      console.log(`ℹ️ Disabling service: ${api}`);
      await disableService(process.env.GCLOUD_PROJECT, api);
    }
  }

  //Finally disable the cloud functions API
  if (disableFunctions) {
    console.log(`ℹ️ Disabling service: ${Constants.SERVICE_CLOUDFUNCTIONS}`);
    await disableService(
      process.env.GCLOUD_PROJECT,
      Constants.SERVICE_CLOUDFUNCTIONS
    );
  }
};

export const executeDisableBilling = async () => {
  if (!process.env.DISABLE_BILLING) {
    console.log("ℹ️ Disable billing is not active, skipping strategy");
    return;
  }

  await disableBillingForProject(process.env.GCLOUD_PROJECT);
};
