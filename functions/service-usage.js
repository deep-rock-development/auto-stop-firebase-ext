import { ServiceUsageClient } from "@google-cloud/service-usage";
const client = new ServiceUsageClient();

export const disableService = async (projectId, serviceName) => {
  const service = `projects/${projectId}/services/${serviceName}`;

  console.log(`🚨📢 Disabling service ${serviceName} for project ${projectId}`);
  await client.disableService({ name: service });
  console.log(`🚨📢 Service ${serviceName} disabled for project ${projectId}`);
};
