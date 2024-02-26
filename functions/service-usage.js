import { ServiceUsageClient } from "@google-cloud/service-usage";
const client = new ServiceUsageClient();

export const disableService = async (projectId, serviceName) => {
  const service = `projects/${projectId}/services/${serviceName}`;
  await client.disableService({ name: service });
  console.log(`Service ${serviceName} disabled for project ${projectId}`);
};

/* 
compute.googleapis.com
storage.googleapis.com
cloudfunctions.googleapis.com
firestore.googleapis.com
pubsub.googleapis.com
identitytoolkit.googleapis.com
*/
