// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";
import { createTopic } from "./pubsub.js";
import {
  createBudget,
  getBillingAccountId,
  findBudgetByName,
} from "./budget.js";

/** Extension lifecycle - triggered onInstall */
export const onInstallFunction = functions.tasks
  .taskQueue()
  .onDispatch(async () => {
    console.log("🚨 EXTENSION INSTALLING 🚨");
    await installExtension();
    console.log("🚨 INSTALLATION DONE 🚨");
  });

/** Trigger from Pub/Sub topic, which in turn will switch services off. */
export const stopTriggered = functions.pubsub
  .topic(process.env.TOPIC_NAME)
  .onPublish(async (message) => {
    // stopServices(); //async?
    await installExtension();
  });

//------------------------------------------------//

export const installExtension = async () => {
  const projectId = process.env.GCLOUD_PROJECT;
  const topicName = process.env.TOPIC_NAME;
  const budgetName = process.env.BUDGET_NAME;
  const stopThreshold = process.env.BUDGET_STOP_THRESHOLD_PERCENT;
  const currency = process.env.BUDGET_CURRENCY;
  const amount = process.env.BUDGET_AMOUNT;

  // await createTopic(topicName);

  console.log("🚨 CREATED TOPIC 🚨");
  const billingAccountId = await getBillingAccountId(projectId);
  console.log(`Found Billing Account ID: ${billingAccountId}`);
  // await createBudget(
  //   billingAccountId,
  //   budgetName,
  //   stopThreshold,
  //   currency,
  //   amount
  // );
  const budget = await findBudgetByName(billingAccountId, budgetName);
  console.log(`Found Budget: ${budget}`);

  console.log("🚨 CREATED BUDGET 🚨");
  console.log("⚠️ NOT IMPLEMENTED ⚠️");
};

export const stopServices = async () => {
  console.log("⚠️ NOT IMPLEMENTED ⚠️");
};
