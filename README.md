# BookWorkflow

##Here are the steps we'll take to look at this workflow.

API: SmartBear_Org/API/1.1.0

The PR fille fail if:
  - An un-resolved Comment is detected
  - Any Standaridization Error is detected
  - The Auto-mock payload does not match the stored Assertion

If no failures are detected the PR will complete:
  - Set the API to Published
  - Set the API to Default
