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
