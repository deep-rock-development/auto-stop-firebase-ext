#!/bin/bash
#
# run-all-tests.sh — run all e2e tests (1-3) sequentially.
#
# BEFORE RUNNING:
#   1. Replace BILLING_ID below with your real GCP billing account ID
#        (find it with: gcloud billing accounts list)
#   2. Install the required CLIs:
#        npm install -g firebase-tools          # Firebase CLI
#        # gcloud: https://cloud.google.com/sdk/docs/install
#   3. Authenticate both:
#        firebase login
#        gcloud auth login
#        gcloud auth application-default login
#
# Tests run sequentially (NOT in parallel): each run overwrites the shared
# ./extensions/functions-auto-stop-billing.env, so concurrent runs would
# clobber each other. Each test creates and tears down its own GCP project.

BILLING_ID=01FE1D-1AEEBA-7C3C7A

SCRIPT_DIR="$(dirname "$0")"
chmod +x "$SCRIPT_DIR/test-extension.sh"
for t in 1 2 3; do
  echo "===== TEST $t ====="
  "$SCRIPT_DIR/test-extension.sh" --billing-id="$BILLING_ID" --test=$t || echo ">>> TEST $t FAILED"
done
