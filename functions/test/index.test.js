//https://www.npmjs.com/package/firebase-functions-test
//https://firebase.google.com/docs/functions/unit-testing

import firebaseFunctionsTest from "firebase-functions-test";
import { onInstallFunction } from "../index.js";

// Extracting `wrap` out of the lazy-loaded features
const { wrap } = firebaseFunctionsTest();

// `jest-ts` example
describe("Validate install function", async () => {
  const wrappedFirebaseFunction = wrap(onInstallFunction);

  // Invoke the firebase function
  const val = await wrappedFirebaseFunction();
  console.log(val);
});
