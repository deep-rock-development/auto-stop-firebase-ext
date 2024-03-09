// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";
import { initializeApp } from "firebase-admin/app";
import { getExtensions } from "firebase-admin/extensions";
import { createTopic } from "./pubsub.js";
import { disableService } from "./service-usage.js";
import * as Constants from "./constants.js";

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
    console.log("⚙️ Received budget alert message...");
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
  //TODO: identify strategy

  //default, disable API
  await executeDisableAPI();
};

export const executeDisableAPI = async () => {
  //disable cloud functions service
  await disableService(
    process.env.GCLOUD_PROJECT,
    Constants.SERVICE_CLOUDFUNCTIONS
  );
};

export const executeCircuitBreaker = async () => {};

export const executeDisableBilling = async () => {};
