## Version 2.0.0

Release Date: 11 June 2026

### Breaking Changes

- **Removed Strategy 2 (Service/API disablement)**, including the `DISABLE_API_LIST` parameter. Billing account removal is now the sole stop strategy.

**Why was Strategy 2 removed?**

Google's Service Usage API no longer allows a service to be disabled while it has live resources. Disable requests now fail server-side with:

> `FAILED_PRECONDITION: Resources are found when disabling service(s) cloudfunctions.googleapis.com. Before you can disable, please delete the following resources first: [...]`

This restriction is documented in Google's [Manage service enablement](https://docs.cloud.google.com/service-usage/docs/hierarchical-service-activation/manage-enablement) guide:

> "Existing resources might prevent you from disabling a service. You can delete these resources and try to disable the service again."

The enforcement is server-side with no override parameter (`disableDependentServices` and `checkIfServiceHasUsage` cover dependent services and 30-day usage, not live resources), and appeared alongside Google's November 2025 Service Usage changes ([release notes](https://docs.cloud.google.com/service-usage/docs/release-notes)). Since the extension cannot disable an API while that service's resources exist — including its own Cloud Functions — Strategy 2 can no longer work reliably, and deleting user resources is out of scope for this extension. Billing account removal remains the reliable cost-stop mechanism and is unaffected.

**Migration**: No action is required. Installs that had Strategy 2 configured will continue to stop costs via billing account removal (if `DISABLE_BILLING` is enabled). The `roles/serviceusage.serviceUsageAdmin` grant is no longer needed and can be revoked from the extension's service account.

### Other Changes

- Removed the `@google-cloud/service-usage` dependency and the `serviceusage.googleapis.com` API requirement
- Renamed the `DISABLE_BILLING` parameter label from "Disable Billing (Strategy 1)" to "Disable Billing" (numbered strategy naming dropped throughout the docs)

## Version 1.1.3

Release Date: 21 April 2026

- Updated runtime to NodeJS v22, due to v20 deprecation

## Version 1.1.2

Release Date: 9 September 2025

- Updated API list to include Speech API

## Version 1.1.1

Release Date: 6 June 2025

- Updated License

## Version 1.1.0

Release Date: 5 June 2025

- Update extension parameters for new APIs which target Firebase APIs specifically
- Updated region locations for function deployment
- Fixed a bug where opt-out of Strategy 1 was not possible.
- Minor reshuffle of logging to reduce log volume.
- Fixed a minor bug where function would throw an error if Strategy 2 was opted-out - note that this bug is purely a logging error and the extension behaves as expected.
- Updated runtime to NodeJS v20, due to 18 deprecation

## Version 1.0.4

Release Date: 13th July 2024

- Further updates to documentation (minor touch ups)
- Removed unnecessary code and general tidy up
- Fixed bug where dependent services for Strategy 2 were stopping service shutdown

## Version 1.0.3

Release Date: 17th March 2024

- Further updates to documentation (minor touch ups)

## Version 1.0.2

Release Date: 17th March 2024

- Updated icon to extensions.yaml
- Updated descriptions in extensions.yaml
- Updated pre and post install documents

## Version 1.0.1

Release Date: 13th March 2024

- Included icon to extensions.yaml

## Version 1.0.0

Release Date: 10th March 2024

### Features

- **Pub/Sub Topic Creation**: Automatically sets up a dedicated Pub/Sub topic for receiving budget alerts.
- **Lifecycle Management**: Implements comprehensive support for extension installation and updates, ensuring seamless integration and maintenance.
- **Budget Alert Subscription**: Establishes a function subscription to the Pub/Sub topic, enabling real-time response to budget alerts.
- **Strategy 1 - Billing Account Removal**: Adds the capability to remove the associated billing account from the project as a cost-control measure, upon reaching a specified budget threshold.
- **Strategy 2 - Service Disablement**: Introduces functionality to disable predefined Google Cloud services, offering a nuanced approach to managing service usage and costs. (Also in response to budget threshold reached)
- **Configurable Parameters**: Provides users with customisable settings to tailor the extension's operation, including:
  - The name of the Pub/Sub topic for budget alerts.
  - The budget threshold percentage that triggers automated actions.
  - Enable/disable toggle for Strategy 1 (Billing Account Removal).
  - Selection of specific APIs for disablement under Strategy 2.

### Improvements

- Enhanced documentation to guide users through the setup and configuration process.
- Refined logging for better clarity and troubleshooting support.

### Fixes

- Addressed issues with parameter validation to ensure reliable extension configuration.
- Resolved intermittent connectivity problems with the Pub/Sub topic subscription.

## Version 0.0.1

- Initial Version
