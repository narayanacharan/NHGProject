# NHGProject

### Infrastructure Components & Workflow

- Two Azure Storage Accounts with Static Website Enabled. (one for blue and one for green)
- An Azure CDN profile with 2 CDN Endpoints pointing to each static website.
- All this infrastructure will be built using an ARM template, even the static website content for blue and green apps.
- I have used DeploymentScript resource to configure the static website with their respective content.
- Written a perster test to test entire infrastructure, includes 16 tests in total. 
- Written a YAML pipeline in Azure DevOps to deploy the infrastructure using ARM template and included pester test as part of the pipeline to test the infrastructure.
- Also parameterized the pipeline to choose between blue and green to make sure there will be minimum/zero downtime while updating respective sites. 
- Pester tests might be minimal due to the time limitations, but they are running effectively with in their context.

### Files and their details
- template.json - ARM Template to deploy infrastructure
- TestAzureCDN.ps1 - Pester test script
- azure-pipelines.yml  - ADO Pipeline
- latestCode/index.html - Sample html to test blue green updates through pipeline. 
