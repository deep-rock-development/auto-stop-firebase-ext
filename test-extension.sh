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
        --project-id=*)
            PROJECT_ID="${1#*=}"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--test=1] [--prefix=custom-prefix]"
            echo "  --test=1    Define which test should be run (default: 0 - Install only)"
            echo "  --billing-id=your-billing-id  Set the billing account ID for the project"
            echo "  --project-id=your-project-id  The project ID for executing the script"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# If no BILLING_ID or TEST_MODE is set, exit
if [[ -z "$BILLING_ID" || -z "$TEST_MODE" || -z "$PROJECT_ID" ]]; then
    echo "Error: --billing-id, --test arguments, and --project-id are required."
    echo "Usage: $0 --billing-id=your-billing-id --test=1 --project-id=your-project-id"
    exit 1
fi

# Enable Cloud Billing API
gcloud services enable cloudbilling.googleapis.com --project="$PROJECT_ID"

# Link the project to the static billing account
gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ID