# BookWorkflow

## Here are the steps of the GitHub Actions workflow CI.

API: SmartBear_Org/API/1.1.0

Initialize:
  - Install Node.js
  - Install the SwaggerHub CLI
  - Install Linux jq utility
  
Start a PR, it will fail:
  - An un-resolved Comment is detected
  - Any Standaridization Error is detected
  - The Auto-mock payload does not match the stored Assertion

If no failures are detected, the PR will complete:
  - Set the API to Published
  - Set the API to Default
