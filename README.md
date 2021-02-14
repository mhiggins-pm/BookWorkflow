# BookWorkflow

## Here are the steps of the GitHub Actions workflow CI.

API: SmartBear_Org/API/1.1.0

Initialize:
  - Install Node.js
  - Install the SwaggerHub CLI
  - Install the Linux jq utility
  
Start a PR, it will fail if:
  - Any un-resolved Comments are detected
  - Any Standardization Errors are detected
  - The Auto-mock payload does not match the stored Assertion

If no failures are detected, the PR will complete:
  - Set the API to Published
  - Set the API to Default
  - Publish the API Documentation to bump.sh
