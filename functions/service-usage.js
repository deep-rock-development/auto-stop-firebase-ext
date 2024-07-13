import { ServiceUsageClient } from "@google-cloud/service-usage";
const client = new ServiceUsageClient();

export const disableService = async (projectId, serviceName) => {
  const service = `projects/${projectId}/services/${serviceName}`;
  try {
    console.log(
      `🚨📢 Disabling service ${serviceName} for project ${projectId}`
    );
    await client.disableService({
      name: service,
      disableDependentServices: true,
    });
    console.log(
      `🚨📢 Service ${serviceName} disabled for project ${projectId}`
    );
  } catch (err) {
    console.error(
      `🚨📢 ERROR!!! disabling service ${serviceName} for project ${projectId}`
    );
    console.error(err);
  }
};
