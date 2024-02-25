import { BudgetServiceClient } from "@google-cloud/billing-budgets";
import { CloudBillingClient } from "@google-cloud/billing";

// Creates a budget client
const client = new BudgetServiceClient();

//Creates billing client
const billingClient = new CloudBillingClient();

export const getBillingAccountId = async (projectId) => {
  const [billingInfo] = await billingClient.getProjectBillingInfo({
    name: `projects/${projectId}`,
  });
  return billingInfo.billingAccountName.split("/").pop();
};

export const findBudgetByName = async (billingAccountId, budgetName) => {
  const parent = `billingAccounts/${billingAccountId}`;
  const [budgets] = await client.listBudgets({ parent });
  const foundBudget = budgets.find(
    (budget) => budget.displayName === budgetName
  );
  return foundBudget; // This will be undefined if no budget with the given name is found
};

export const createBudget = async (
  billingAccountId,
  projectId,
  budgetName,
  topicName,
  stopThreshold,
  currency,
  amount
) => {
  // Creates a budget

  console.log(`🚨 Creating Budget for ${billingAccountId} 🚨`);
  const [budget] = await client.createBudget({
    parent: client.billingAccountPath(billingAccountId),
    budget: {
      displayName: budgetName,
      amount: {
        specifiedAmount: {
          currencyCode: currency,
          units: amount,
        },
      },
      budgetFilter: {
        projects: [`projects/${projectId}`],
      },
      thresholdRules: [
        { thresholdPercent: stopThreshold }, // Notify at X% spend
      ],
      notificationsRule: {
        pubsubTopic: `projects/${projectId}/topics/${topicName}`, // Replace with your Pub/Sub topic
        schemaVersion: "1.0",
        notificationChannelIds: [], // Optional: Specify notification channel IDs if needed
      },
    },
  });

  console.log(`✅ Budget created: ${budget.name}`);
  return budget;
};

export const disableBillingForProject = async (projectId) => {
  console.log(`🚨📢 Disabling billing for ${projectId}...`);
  const projectName = `projects/${projectId}`;
  const billingInfo = {
    name: projectName,
    billingAccountName: "", // An empty string disables billing
  };

  await billingClient.updateProjectBillingInfo({
    name: projectName,
    projectBillingInfo: billingInfo,
  });
  console.log(`🚨📢 Billing disabled for ${projectId}`);
};
