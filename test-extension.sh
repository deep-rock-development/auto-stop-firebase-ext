#!/bin/bash

# Exit on any error
set -e

TEST_MODE=0
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
        -h|--help)
            echo "Usage: $0 [--test=1] [--prefix=custom-prefix]"
            echo "  --test=1    Define which test should be run (default: 0 - Install only)"
            echo "  --billing-id=your-billing-id  Set the billing account ID for the project"
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


# Create GCP project with firebase added
PROJECT_ID="fb-test-asb-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -c1-8)"
echo "Creating project: $PROJECT_ID"
firebase projects:create $PROJECT_ID --non-interactive

# Link the project to the static billing account
gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ID

# Deploy extension with retry logic (IAM propagation can take a while)
echo "Deploying extension with retry logic..."
RETRY_COUNT=0
MAX_RETRIES=3
WAIT_TIME=30

# Get right config template based on test mode, if test mode is >= 4 use s2, otherwise use s1
if [ "$TEST_MODE" -ge 4 ]; then
    echo "Using extension config for S2 tests."
    CONFIG_TEMPLATE="extension-s2-config.template"
else
    echo "Using extension config for S1 tests."
    CONFIG_TEMPLATE="extension-s1-config.template"
fi

# Configure extension parameters
mkdir -p extensions
cp -f $CONFIG_TEMPLATE ./extensions/functions-auto-stop-billing.env

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if firebase deploy --force --project $PROJECT_ID; then
        echo "Firebase deploy successful!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Deploy failed. Waiting ${WAIT_TIME}s before retry ${RETRY_COUNT}/${MAX_RETRIES}..."
            sleep $WAIT_TIME
        else
            echo "Deploy failed after $MAX_RETRIES attempts."
            exit 1
        fi
    fi
done

# Create a budget and link to the topic
gcloud billing budgets create \
  --billing-account=$BILLING_ID \
  --display-name="$PROJECT_ID-budget" \
  --budget-amount=5USD \
  --threshold-rule=percent=0.5,basis=CURRENT_SPEND \
  --threshold-rule=percent=0.9,basis=CURRENT_SPEND \
  --threshold-rule=percent=1.0,basis=CURRENT_SPEND \
  --filter-projects=projects/$PROJECT_ID \
  --notifications-rule-pubsub-topic=projects/$PROJECT_ID/topics/ext-firebase-trigger-auto-stop \
  --project=$PROJECT_ID

# Find the extension service account and assign roles/billing.projectManager and roles/serviceusage.service
SERVICE_ACCOUNT=$(gcloud iam service-accounts list --format="value(email)" --filter="email~ext-functions-auto-stop" --project=$PROJECT_ID)
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/billing.projectManager" --project=$PROJECT_ID
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/serviceusage.serviceUsageAdmin" --project=$PROJECT_ID

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
    4)
        echo "TEST 4: [STARTED] - Test disable all APIs (some enabled, some not)"
        # Send a message to the pub/sub topic to trigger the function
        echo "TEST 4: [RUNNING] - Sending alert with threshold to trigger disable"
        MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","alertThresholdExceeded":1.0,"testMode":4}'
        gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID

        sleep 30

        # Get list of currently enabled APIs
        ENABLED_APIS=$(gcloud services list --enabled --format="value(config.name)" --project=$PROJECT_ID)
        echo $ENABLED_APIS
        # APIs that should be disabled
        DISABLED_API_LIST="firebasestorage.googleapis.com,cloudfunctions.googleapis.com,firestore.googleapis.com,firebasehosting.googleapis.com,firebasedatabase.googleapis.com,firebaseml.googleapis.com,mlkit.googleapis.com,firebasevertexai.googleapis.com,speech.googleapis.com,fcm.googleapis.com,identitytoolkit.googleapis.com,firebaseextensions.googleapis.com,pubsub.googleapis.com,compute.googleapis.com,storage.googleapis.com"
        
        # Check if any of the APIs from the disable list are still enabled
        FOUND_ENABLED=false
        IFS=',' read -ra APIS <<< "$DISABLED_API_LIST"
        for api in "${APIS[@]}"; do
            if echo "$ENABLED_APIS" | grep -Fx "$api" > /dev/null; then
                echo "TEST 4: [FAILED] - API $api is still enabled"
                FOUND_ENABLED=true
            fi
        done
        
        if [ "$FOUND_ENABLED" = true ]; then
            echo "TEST 4: [FAILED] - Some APIs that should be disabled are still enabled"
            exit 1
        else
            echo "TEST 4: [SUCCESS] - All specified APIs have been disabled"
        fi
        ;;
    5)
        echo "TEST 5: [STARTED] - Disable ALL APIs (all enabled)"

        # enable the APIs first
        echo "TEST 5: [RUNNING] - Enabling APIs before testing disable"
        API_LIST="firebasestorage.googleapis.com,cloudfunctions.googleapis.com,firestore.googleapis.com,firebasehosting.googleapis.com,firebasedatabase.googleapis.com,firebaseml.googleapis.com,mlkit.googleapis.com,firebasevertexai.googleapis.com,speech.googleapis.com,fcm.googleapis.com,identitytoolkit.googleapis.com,firebaseextensions.googleapis.com,pubsub.googleapis.com,compute.googleapis.com,storage.googleapis.com"
        
        # Enable APIs one by one
        IFS=',' read -ra APIS <<< "$API_LIST"
        for api in "${APIS[@]}"; do
            echo "Enabling $api..."
            gcloud services enable "$api" --project=$PROJECT_ID
        done

        # Check APIs are enabled
        ENABLED_APIS=$(gcloud services list --enabled --format="value(config.name)" --project=$PROJECT_ID)
        
        FOUND_ENABLED=false
        IFS=',' read -ra APIS <<< "$API_LIST"
        for api in "${APIS[@]}"; do
            if ! echo "$ENABLED_APIS" | grep -Fx "$api" > /dev/null; then
                echo "TEST 5: [FAILED] - API $api is not enabled"
                FOUND_ENABLED=true
            fi
        done
        
        # Send a message to the pub/sub topic to trigger the function
        echo "TEST 5: [RUNNING] - Sending alert with threshold to trigger disable"
        MESSAGE='{"budgetDisplayName":"'$PROJECT_ID'-budget","alertThresholdExceeded":1.0,"testMode":4}'
        gcloud pubsub topics publish ext-firebase-trigger-auto-stop --message="$MESSAGE" --project=$PROJECT_ID

        sleep 30

        # Get list of currently enabled APIs
        ENABLED_APIS=$(gcloud services list --enabled --format="value(config.name)" --project=$PROJECT_ID)
        
        # Check if any of the APIs from the disable list are still enabled
        FOUND_ENABLED=false
        IFS=',' read -ra APIS <<< "$API_LIST"
        for api in "${APIS[@]}"; do
            if echo "$ENABLED_APIS" | grep -Fx "$api" > /dev/null; then
                echo "TEST 5: [FAILED] - API $api is still enabled"
                FOUND_ENABLED=true
            fi
        done
        
        if [ "$FOUND_ENABLED" = true ]; then
            echo "TEST 5: [FAILED] - Some APIs that should be disabled are still enabled"
            exit 1
        else
            echo "TEST 5: [SUCCESS] - All specified APIs have been disabled"
        fi
        ;;
    *)
        echo "Unknown test mode: $TEST_MODE"
        exit 1
        ;;
esac

# If test mode is 0, skip cleanup
if [ "$TEST_MODE" -eq 0 ]; then
    echo "Skipping cleanup as test mode is 0 (installation only)."
    exit 0
fi

# Clean up resources (close project)
echo "Cleaning up resources..."
gcloud projects delete $PROJECT_ID --quiet


echo "Script execution completed!"