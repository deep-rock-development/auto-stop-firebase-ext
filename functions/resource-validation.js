import { ProjectsClient } from "@google-cloud/resource-manager";

// Initialize the client
const projectsClient = new ProjectsClient();

export const testIamPermissions = async (projectId) => {
  const resource = `projects/${projectId}`;
  const permissions = [
    "serviceusage.services.disable",
    "resourcemanager.projects.deleteBillingAssignment",
  ];

  try {
    const [response] = await projectsClient.testIamPermissions({
      resource,
      permissions,
    });

    console.log("Permissions allowed:", response.permissions);
    // Check if the response.permissions array includes the permissions:
    permissions.forEach((perm) => {
      if (response.permissions && response.permissions.includes(perm)) {
        console.log(`✅ Permission granted: ${perm}`);
      } else {
        console.error(`⛔ Permission not granted: ${perm}`);
      }
    });
  } catch (error) {
    console.error("⛔ Error testing IAM permissions:", error);
  }
};
