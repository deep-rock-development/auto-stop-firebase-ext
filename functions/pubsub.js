import { PubSub } from "@google-cloud/pubsub";

// Initialize Pub/Sub client
const pubsub = new PubSub();

export const createTopic = async (topicName) => {
  await pubsub.createTopic(topicName);
  console.log(`✅ Topic ${topicName} created.`);
};
