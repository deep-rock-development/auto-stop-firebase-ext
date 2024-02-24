// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";

/** Extension lifecycle - triggered onInstall */
export const onInstallFunction = functions.tasks
  .taskQueue()
  .onDispatch(async () => {
    await installExtension();
  });

/** Trigger from Pub/Sub topic, which in turn will switch services off. */
export const stopTriggered = functions.pubsub
  .topic("stop-topic")
  .onPublish(async (message, context) => {
    await stopServices();
  });

//------------------------------------------------//

export const installExtension = async () => {
  console.log("⚠️ NOT IMPLEMENTED ⚠️");
};

export const stopServices = async () => {
  console.log("⚠️ NOT IMPLEMENTED ⚠️");
};
