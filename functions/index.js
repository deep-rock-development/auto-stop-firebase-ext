// Import the firebase-functions package using ES module syntax
import * as functions from "firebase-functions";

export const greetTheWorld = functions.https.onRequest((req, res) => {
  // Here we reference a user-provided parameter
  // (its value is provided by the user during installation)
  const consumerProvidedGreeting = process.env.GREETING;

  // And here we reference an auto-populated parameter
  // (its value is provided by Firebase after installation)
  const instanceId = process.env.EXT_INSTANCE_ID;

  const greeting = `Hello World from ${instanceId}`;

  res.send(greeting);
});
