#!/bin/bash

# Exit on any error
set -e

# Always operate from the repository root (this script lives in e2e/);
# firebase deploy and the extensions/ env dir are resolved relative to it.
cd "$(dirname "$0")/.."

TEST_MODE=0
KEEP_PROJECT=false
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --test=*)
            TEST_MODE="${1#*=}"
            shift
            ;;
         --billing-id=*)
            BILLING_ID="${1#*=}"
            shift
            ;;
        --keep-project)
            KEEP_PROJECT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--test=1] [--keep-project]"
            echo "  --test=1    Define which test should be run (default: 0 - Install only)"
            echo "  --billing-id=your-billing-id  Set the billing account ID for the project"
            echo "  --keep-project  Keep the test project after the run (default: delete, even on failure)"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# If no BILLING_ID or TEST_MODE is set, exit
if [[ -z "$BILLING_ID" || -z "$TEST_MODE" ]]; then
    echo "Error: --billing-id and --test arguments are required."
    echo "Usage: $0 --billing-id=your-billing-id --test=1"
    exit 1
fi

# Install-only mode keeps the project (nothing to inspect otherwise)
if [ "$TEST_MODE" -eq 0 ]; then
    KEEP_PROJECT=true
fi

# Delete the test project on ANY exit (success or failure) unless --keep-project.
# Leaked fb-test-asb-* projects count against the billing-account link quota,
# which silently breaks all future extension installs once exceeded.
cleanup() {
    EXIT_CODE=$?
    if [[ -z "$PROJECT_ID" ]]; then
        return
    fi
    if [[ "$KEEP_PROJECT" == "true" ]]; then
        echo "ℹ️ Keeping project $PROJECT_ID (delete manually: gcloud projects delete $PROJECT_ID --quiet)"
        return
    fi
    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "Run failed (exit $EXIT_CODE). Deleting project $PROJECT_ID — rerun with --keep-project to inspect failures."
    else
        echo "Cleaning up resources..."
    fi
    gcloud projects delete "$PROJECT_ID" --quiet \
        || echo "WARNING: could not delete $PROJECT_ID — delete it manually (billing quota risk)"
}
trap cleanup EXIT


# Create GCP project with firebase added
PROJECT_ID="fb-test-asb-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -c1-8)"
echo "Creating project: $PROJECT_ID"
firebase projects:create $PROJECT_ID --non-interactive

# Link the project to the static billing account
gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ID

# Pre-provision the Cloud Functions service agent and grant it Artifact Registry
# read access. On fresh projects the auto-grant races with the first deploy,
# causing: "Unable to retrieve the repository metadata for .../gcf-artifacts"
gcloud services enable cloudfunctions.googleapis.com artifactregistry.googleapis.com --project=$PROJECT_ID
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud beta services identity create --service=cloudfunctions.googleapis.com --project=$PROJECT_ID || true
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcf-admin-robot.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader" --condition=None --quiet > /dev/null

# Deploy extension with retry logic (IAM propagation can take a while)
echo "Deploying extension with retry logic..."
RETRY_COUNT=0
MAX_RETRIES=3
WAIT_TIME=30

# Single config template (API-disable strategy removed in 2.0.0)
CONFIG_TEMPLATE="e2e/extension-s1-config.template"

# Configure extension parameters
mkdir -p extensions
cp -f $CONFIG_TEMPLATE ./extensions/functions-auto-stop-billing.env

# Capture full deploy output so failures are diagnosable after the fact
mkdir -p logs
DEPLOY_LOG="logs/${PROJECT_ID}-deploy.log"

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "===== deploy attempt $((RETRY_COUNT + 1))/$MAX_RETRIES =====" >> "$DEPLOY_LOG"
    firebase deploy --force --project $PROJECT_ID 2>&1 | tee -a "$DEPLOY_LOG"
    DEPLOY_STATUS=${PIPESTATUS[0]}
    if [ $DEPLOY_STATUS -eq 0 ]; then
        echo "Firebase deploy successful!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Deploy failed. Waiting ${WAIT_TIME}s before retry ${RETRY_COUNT}/${MAX_RETRIES}..."
            sleep $WAIT_TIME
        else
            echo "Deploy failed after $MAX_RETRIES attempts."
            echo "===== last 40 lines of $DEPLOY_LOG ====="
            tail -40 "$DEPLOY_LOG"
            exit 1
        fi
    fi
done

# Create a budget and link to the topic
gcloud billing budgets create \
  --billing-account=$BILLING_ID \
  --display-name="$PROJECT_ID-budget" \
  --budget-amount=5 \
  --threshold-rule=percent=0.5,basis=CURRENT_SPEND \
  --threshold-rule=percent=0.9,basis=CURRENT_SPEND \
  --threshold-rule=percent=1.0,basis=CURRENT_SPEND \
  --filter-projects=projects/$PROJECT_ID \
  --notifications-rule-pubsub-topic=projects/$PROJECT_ID/topics/ext-firebase-trigger-auto-stop \
  --project=$PROJECT_ID

# Find the extension service account and assign roles/billing.projectManager
SERVICE_ACCOUNT=$(gcloud iam service-accounts list --format="value(email)" --filter="email~ext-functions-auto-stop" --project=$PROJECT_ID)
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/billing.projectManager" --project=$PROJECT_ID

# Publish a message to the pub/sub topic
MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","extensionTest":true}'
gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID

echo "Project $PROJECT_ID created and configured successfully!"

# Run tests based on test mode
case "$TEST_MODE" in
    0)
        echo "No tests to run - installation only."
        ;;
    1)
        echo "TEST 1: [STARTED] - Alert threshold below budget"
        # Send a message to the pub/sub topic to trigger the function
        echo "TEST 1: [RUNNING] - Sending alert for 99% threshold (should not trigger billing shutdown)"
        MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","alertThresholdExceeded":0.9,"testMode":1}'
        gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID

        sleep 30

        # Check if project still has an active billing account
        ACTIVE_BILLING=$(gcloud billing projects describe $PROJECT_ID --format="value(billingAccountName)" --project=$PROJECT_ID)
        # Check if the billing account is still linked
        if [[ -z "$ACTIVE_BILLING" ]]; then
            echo "TEST 1: [FAILED] - Billing account is not linked"
            exit 1
        fi
        echo "TEST 1: [SUCCESS] - Billing account is still linked"
        ;;
    2)
        echo "TEST 2: [STARTED] - Alert threshold equal to budget"
        # Send a message to the pub/sub topic to trigger the function
        echo "TEST 2: [RUNNING] - Sending alert for 100% threshold (should trigger billing shutdown)"
        MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","alertThresholdExceeded":1.0,"testMode":2}'
        gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID
        sleep 30
        # Check if project has been stopped
        ACTIVE_BILLING=$(gcloud billing projects describe $PROJECT_ID --format="value(billingAccountName)" --project=$PROJECT_ID)
        if [[ -n "$ACTIVE_BILLING" ]]; then
            echo "TEST 2: [FAILED] - Billing account is still linked"
            exit 1
        fi
        echo "TEST 2: [SUCCESS] - Billing account has been removed"

        ;;
    3)
        echo "TEST 3: [STARTED] - No alert threshold in message payload"
        # Send a message to the pub/sub topic to trigger the function
        echo "TEST 3: [RUNNING] - Sending alert with no threshold (should not trigger billing shutdown)"
        MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","testMode":3}'
        gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID

        sleep 30

        # Check if project still has an active billing account
        ACTIVE_BILLING=$(gcloud billing projects describe $PROJECT_ID --format="value(billingAccountName)" --project=$PROJECT_ID)
        # Check if the billing account is still linked
        if [[ -z "$ACTIVE_BILLING" ]]; then
            echo "TEST 3: [FAILED] - Billing account is not linked"
            exit 1
        fi
        echo "TEST 3: [SUCCESS] - Billing account is still linked"
        ;;
    *)
        echo "Unknown test mode: $TEST_MODE"
        exit 1
        ;;
esac

# Cleanup is handled by the EXIT trap (see cleanup() above)
echo "Script execution completed!"