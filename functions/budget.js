import BudgetServiceClient from "@google-cloud/billing-budgets";

// Creates a budget client
const client = new BudgetServiceClient();

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
        { thresholdPercent: stopThreshold }, // Notify at 90% spend
      ],
      notificationsRule: {
        pubsubTopic: `projects/${projectId}/topics/${topicName}`, // Replace with your Pub/Sub topic
        schemaVersion: "1.0",
        notificationChannelIds: [], // Optional: Specify notification channel IDs if needed
      },
    },
  });

  console.log(`✅ Budget created: ${budget.name}`);
};
