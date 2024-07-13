import { CloudBillingClient } from "@google-cloud/billing";

//Creates billing client
const billingClient = new CloudBillingClient();

/**
 * Given a project ID, disables billing for the project by
 *  setting the billing account to an empty string
 * @param {String} projectId for the Firebase project
 */
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
