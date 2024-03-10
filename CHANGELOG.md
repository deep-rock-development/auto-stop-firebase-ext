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
