// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";

/**
 * Extension lifecycle - triggered onInstall
 */
export const onInstallFunction = functions.tasks
  .taskQueue()
  .onDispatch(async () => {
    // Complete your lifecycle event handling task.
    // ...
    console.log("⚠️ NOT IMPLEMENTED ⚠️");
    //TODO: Add content
  });

/**
 * Trigger from Pub/Sub topic, which in turn will switch services off.
 */
export const stopTriggered = functions.pubsub
  .topic("stop-topic")
  .onPublish((message, context) => {
    console.log("⚠️ NOT IMPLEMENTED ⚠️");
    //TODO: Add content
  });
