// Import the firebase-functions package using ES module syntax

import { getExtensions } from "firebase-admin/extensions";
import { createTopic } from "./pubsub.js";
import { disableService } from "./service-usage.js";
import * as Constants from "./constants.js";
import { disableBillingForProject } from "./budget.js";
import { testIamPermissions } from "./resource-validation.js";

/**
 * Installs the extension by creating a Pub/Sub topic
 *
 * @returns None
 */
export const installExtension = async () => {
  try {
    console.log("⚙️ Installing extension...");
    const topicName = process.env.TOPIC_NAME;

    console.log("⚙️ Creating topic...");
    await createTopic(topicName);

    getExtensions().runtime().setProcessingState("PROCESSING_COMPLETE");
    console.log("✅ Extension installed successfully");
    return;
  } catch (error) {
    console.error(`❌ Failed to install extension:`, error);
    getExtensions().runtime().setProcessingState("PROCESSING_FAILED");
    throw error;
  }
};

/**
 * Triggers the firebase function when a message is received from the topic
 *  will stop services if the message content satisfies the conditions
 * @returns None
 */
export const stopServices = async (message) => {
  const messageData = message.data
    ? Buffer.from(message.data, "base64").toString()
    : null;

  // Parse the message data as JSON
  const data = messageData ? JSON.parse(messageData) : null;

  // Validate if the message is a test message
  if (data.extensionTest) {
    console.log("ℹ️ Received budget alert message with test parameter");
    await testIamPermissions(process.env.GCLOUD_PROJECT);
    return;
  }

  // Validate that the payload included budget information
  if (!data.alertThresholdExceeded) {
    console.log("🚨 Alert raised, but there was no budget data in the payload");
    return;
  }

   // Validate that there is a threshold identified
  if (!process.env.BUDGET_STOP_THRESHOLD_PERCENT) {
    console.log("🚨 Alert raised, but there was no budget threshold set");
    return;
  }

  console.log(
    `🚨 Alert: ${data.alertThresholdExceeded} : Configuration: ${process.env.BUDGET_STOP_THRESHOLD_PERCENT}`
  );

  // Validate if the alert threshold has been exceeded
  if (data.alertThresholdExceeded < process.env.BUDGET_STOP_THRESHOLD_PERCENT) {
    console.log("✅ Budget below threshold, services are online");
    return;
  }

  console.log("⛔ Budget threshold has been reached, shutting down services");
  await executeDisable();
};

/**
 * Executes the disable strategy
 */
export const executeDisable = async () => {
  await executeDisableBilling();
  await executeDisableAPI();
};
/**
 * Validates that there is a list of services provided.
 *  If none, ignore this process
 *  If services selected, explicitly disable these services
 * @returns None
 */
export const executeDisableAPI = async () => {
  
  // Validate that there are services to disable (or at least the var is non-null)
  if (!process.env.DISABLE_API_LIST) {
    console.log("ℹ️ No services to disable");
    return;
  }

  // Extract selected APIs
  const disableApiList = process.env.DISABLE_API_LIST.split(",");
  let disableFunctions = false;
  console.log(`ℹ️ List of services to disable: ${disableApiList}`);

  // Validate that there are services to disable
  if (disableApiList.length === 0) {
    console.log("ℹ️ No services to disable");
    return;
  }

  // Iterate through selected APIs and disable one-by-one
  for (const api of disableApiList) {
    // We need to disable cloud functions last
    if (api === Constants.SERVICE_CLOUDFUNCTIONS) {
      disableFunctions = true;
    } else {
      console.log(`ℹ️ Disabling service: ${api}`);
      await disableService(process.env.GCLOUD_PROJECT, api);
    }
  }

  // Finally disable the cloud functions API
  if (disableFunctions) {
    console.log(`ℹ️ Disabling service: ${Constants.SERVICE_CLOUDFUNCTIONS}`);
    await disableService(
      process.env.GCLOUD_PROJECT,
      Constants.SERVICE_CLOUDFUNCTIONS
    );
  }
};

/**
 * Validates that billing is to be disabled
 *  If false, ignore this process
 *  If true, remove the billing account from project
 * @returns None
 */
export const executeDisableBilling = async () => {
  if (process.env.DISABLE_BILLING === 'false') {
    console.log("ℹ️ Disable billing is not active, skipping strategy");
    return;
  }

  await disableBillingForProject(process.env.GCLOUD_PROJECT);
};
