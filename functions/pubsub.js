import { PubSub } from "@google-cloud/pubsub";

// Initialize Pub/Sub client
const pubsub = new PubSub();

export const createTopic = async (topicName) => {
  try {
    await pubsub.createTopic(topicName);
    console.log(`✅ Topic ${topicName} created.`);
  } catch (error) {
    if (error.code === 6) {
      console.log(`ℹ️ Topic ${topicName} already exists.`);
    } else {
      console.error(`❌ Failed to create topic ${topicName}:`, error);
      throw error; // Rethrow if you want to escalate the error
    }
  }
};
