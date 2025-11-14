---
title: "Azure Pipelines Best Practices for Stacks Azure Data Platform"
author: "Ensono Stacks"
created: "2025-11-14"
purpose: "Comprehensive guide for Azure DevOps pipeline development following Microsoft best practices"
---

# Azure Pipelines Best Practices for Stacks Azure Data Platform

## Table of Contents

- [Introduction](#introduction)
- [Pipeline Architecture](#pipeline-architecture)
- [Security Best Practices](#security-best-practices)
- [Template Design Patterns](#template-design-patterns)
- [Task Reproducibility with eirctl](#task-reproducibility-with-eirctl)
- [Triggers and CI/CD Automation](#triggers-and-cicd-automation)
- [Approvals and Deployment Gates](#approvals-and-deployment-gates)
- [Performance Optimization](#performance-optimization)
- [Variables and Parameters](#variables-and-parameters)
- [Testing Strategies](#testing-strategies)
- [Monitoring and Observability](#monitoring-and-observability)
- [Project-Specific Guidelines](#project-specific-guidelines)

---

## Introduction

This document provides comprehensive guidance for developing Azure DevOps pipelines for the Ensono Stacks Azure Data Platform. It combines Microsoft's official best practices with project-specific patterns, emphasizing the use of **eirctl** for task reproducibility and standardization.

### Core Principles

1. **Reproducibility**: All pipeline tasks should be reproducible locally using eirctl
2. **Security-First**: Never compromise security controls for convenience
3. **Template-Driven**: Reuse templates to ensure consistency and reduce duplication
4. **Fail-Fast**: Detect issues early in the pipeline to reduce feedback cycles
5. **Observable**: Comprehensive logging and monitoring at every stage

---

## Pipeline Architecture

### Multi-Stage Pipeline Structure

Azure Pipelines supports multi-stage YAML pipelines that provide isolation, quality control, and better visibility. The Stacks platform uses a standard structure:

```yaml
name: "$(Build.SourceBranchName)-descriptive-name"

trigger:
  branches:
    include:
      - main
      - feature/*
  paths:
    include:
      - "relevant/path/**"
    exclude:
      - "**/*.md"
      - ".github/**"

pr:
  branches:
    include:
      - main
  paths:
    include:
      - "relevant/path/**"

stages:
  - stage: Build
    displayName: "Build and Validate"
    jobs:
      - job: Validate
        # Build and validation tasks

  - stage: Test
    displayName: "Run Tests"
    dependsOn: Build
    jobs:
      - job: UnitTests
        # Unit test execution

  - stage: Deploy_NonProd
    displayName: "Deploy to Non-Production"
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployInfra
        environment: "nonprod"
        # Deployment tasks

  - stage: Deploy_Prod
    displayName: "Deploy to Production"
    dependsOn: Deploy_NonProd
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployInfra
        environment: "prod"
        # Production deployment tasks
```

### Stage Dependencies and Conditions

**Best Practice**: Use explicit stage dependencies and conditions to control flow:

```yaml
stages:
  - stage: Build
    jobs:
      - job: BuildApp
        # Build tasks

  - stage: SecurityScan
    dependsOn: Build
    condition: succeeded('Build')
    jobs:
      - job: ScanArtifacts
        # Security scanning

  - stage: Deploy
    dependsOn:
      - Build
      - SecurityScan
    condition: |
      and(
        succeeded('Build'),
        succeeded('SecurityScan'),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
    jobs:
      - deployment: DeployToEnvironment
        # Deployment
```

**Key Points**:

- Use `dependsOn` to establish explicit dependencies
- Use `condition` to control when stages execute
- Fail-fast by checking previous stage success
- Use branch conditions to protect production deployments

### Job Isolation

Each job runs on a separate agent (or the same agent in sequence). Use jobs to:

- Isolate different tasks (build vs. test vs. deploy)
- Run tasks in parallel where possible
- Provide clear separation of concerns

```yaml
jobs:
  - job: BuildLinux
    pool:
      vmImage: "ubuntu-latest"
    steps:
      - task: eirctl
        # Build tasks

  - job: BuildWindows
    pool:
      vmImage: "windows-latest"
    steps:
      - task: eirctl
        # Windows-specific build
```

---

## Security Best Practices

### Secret Management

**CRITICAL**: Follow the comprehensive security guidelines in [copilot-security-instructions.md](../.github/copilot-security-instructions.md).

#### Use Azure Key Vault Integration

```yaml
variables:
  - group: "ensono-data-euw-data-nonprod-infra" # Variable group linked to Key Vault

steps:
  - task: AzureKeyVault@2
    displayName: "Get secrets from Key Vault"
    inputs:
      azureSubscription: "$(service_connection_name)"
      KeyVaultName: "$(key_vault_name)"
      SecretsFilter: "*"
      RunAsPreJob: true
```

#### Never Hardcode Secrets

❌ **NEVER DO THIS**:

```yaml
# WRONG - Secrets exposed in pipeline
variables:
  DATABASE_PASSWORD: "MyP@ssw0rd123!"
  API_KEY: "sk-1234567890abcdef"
```

✅ **DO THIS INSTEAD**:

```yaml
variables:
  - group: "secure-variables" # Linked to Key Vault

steps:
  - task: AzureCLI@2
    displayName: "Use managed identity"
    inputs:
      azureSubscription: "$(service_connection_name)"
      scriptType: "bash"
      scriptLocation: "inlineScript"
      inlineScript: |
        # Secrets retrieved at runtime via managed identity
        az keyvault secret show --vault-name $(key_vault_name) --name db-password
```

#### Enable Shell Parameter Validation

Prevent command injection by enabling shell parameter validation:

```yaml
# Enable at organization or project level:
# Settings > Pipelines > Settings > "Enable shell tasks arguments parameter validation"
```

#### Use Runtime Parameters for User Input

```yaml
parameters:
  - name: environment
    type: string
    displayName: "Target Environment"
    default: "dev"
    values:
      - dev
      - qa
      - uat
      - prod

  - name: deploymentApproved
    type: boolean
    displayName: "Deployment Approved by CAB"
    default: false

stages:
  - stage: Deploy
    condition: eq('${{ parameters.deploymentApproved }}', 'true')
    jobs:
      - job: DeployInfrastructure
        variables:
          targetEnv: "${{ parameters.environment }}"
```

**Benefits**:

- Type-safe input validation
- Prevents arbitrary variable injection
- Provides clear UI for pipeline execution
- Audit trail of parameter values

### Protected Resources

Configure pipeline permissions for protected resources:

1. **Environments**: Require approval for production deployments
2. **Service Connections**: Restrict to specific pipelines
3. **Variable Groups**: Grant access only to authorized pipelines
4. **Agent Pools**: Limit access to sensitive build agents
5. **Repositories**: Control cross-repo access

```yaml
resources:
  repositories:
    - repository: templates
      type: git
      name: Contoso/BuildTemplates
      ref: refs/heads/main # Pin to specific commit for security

  pipelines:
    - pipeline: security-scan
      source: security-lib-ci
      trigger:
        branches:
          include:
            - main
```

### Secure Task Execution

Restrict what tasks can do using the `target` property:

```yaml
steps:
  - task: PowerShell@2
    displayName: "Run restricted script"
    target:
      commands: restricted # Prevents arbitrary command execution
      settableVariables:
        - expectedVar
        - ok* # Only allow variables starting with 'ok'
    inputs:
      targetType: "inline"
      script: |
        Write-Host "Running with restricted permissions"
        # Cannot set arbitrary variables
```

---

## Template Design Patterns

### Template Types

Azure Pipelines supports two main template types:

1. **Include Templates**: Insert reusable content
2. **Extends Templates**: Define schema and enforce standards

### Include Templates

Use include templates for common task sequences:

**Template: `templates/install-eirctl.yml`**

```yaml
parameters:
  - name: EirctlVersion
    type: string
    default: "v0.9.6"

steps:
  - task: Bash@3
    displayName: "Install: Eirctl ${{ parameters.EirctlVersion }}"
    inputs:
      targetType: inline
      script: |
        sudo wget https://github.com/Ensono/eirctl/releases/download/${{ parameters.EirctlVersion }}/eirctl-linux-amd64 -O /usr/local/bin/eirctl
        sudo chmod +x /usr/local/bin/eirctl
        eirctl version
```

**Consuming Pipeline:**

```yaml
steps:
  - template: templates/install-eirctl.yml
    parameters:
      EirctlVersion: "v0.9.6"
```

### Stage Templates

Create reusable stage configurations:

**Template: `templates/terraform-deploy.yml`**

```yaml
parameters:
  - name: stageName
    type: string
  - name: environment
    type: string
  - name: tfWorkingDirectory
    type: string
  - name: serviceConnection
    type: string
  - name: dependsOn
    type: object
    default: []

stages:
  - stage: ${{ parameters.stageName }}
    displayName: "Terraform Deploy - ${{ parameters.environment }}"
    dependsOn: ${{ parameters.dependsOn }}
    jobs:
      - job: TerraformDeploy
        steps:
          - template: install-eirctl.yml

          - task: Bash@3
            displayName: "Terraform Init"
            inputs:
              targetType: "inline"
              script: |
                cd ${{ parameters.tfWorkingDirectory }}
                eirctl run infra:init
            env:
              ARM_CLIENT_ID: $(arm_client_id)
              ARM_TENANT_ID: $(arm_tenant_id)

          - task: Bash@3
            displayName: "Terraform Plan"
            inputs:
              targetType: "inline"
              script: |
                cd ${{ parameters.tfWorkingDirectory }}
                eirctl run infra:plan
```

**Consuming Pipeline:**

```yaml
stages:
  - template: templates/terraform-deploy.yml
    parameters:
      stageName: "DeployDev"
      environment: "dev"
      tfWorkingDirectory: "$(System.DefaultWorkingDirectory)/deploy/terraform/infra"
      serviceConnection: "azure-service-connection"

  - template: templates/terraform-deploy.yml
    parameters:
      stageName: "DeployProd"
      environment: "prod"
      tfWorkingDirectory: "$(System.DefaultWorkingDirectory)/deploy/terraform/infra"
      serviceConnection: "azure-service-connection"
      dependsOn:
        - DeployDev
```

### Extends Templates

Use extends templates to enforce security and compliance:

**Template: `templates/secure-pipeline.yml`**

```yaml
parameters:
  - name: stages
    type: stageList
    default: []

stages:
  # Inject security scanning before user stages
  - stage: SecurityScan
    displayName: "Security Compliance Scan"
    jobs:
      - job: CredentialScan
        steps:
          - task: CredScan@3
            displayName: "Scan for credentials"

      - job: DependencyCheck
        steps:
          - task: dependency-check@6
            displayName: "Check for vulnerable dependencies"

  # User-defined stages
  - ${{ each stage in parameters.stages }}:
      - stage: ${{ stage.stage }}
        displayName: ${{ stage.displayName }}
        dependsOn:
          - SecurityScan
          - ${{ stage.dependsOn }}
        jobs: ${{ stage.jobs }}

  # Inject compliance reporting after all stages
  - stage: ComplianceReport
    displayName: "Generate Compliance Report"
    dependsOn: ${{ parameters.stages }}
    condition: always()
    jobs:
      - job: GenerateReport
        steps:
          - task: PublishComplianceReport@1
```

**Consuming Pipeline:**

```yaml
extends:
  template: templates/secure-pipeline.yml
  parameters:
    stages:
      - stage: Build
        displayName: "Build Application"
        jobs:
          - job: BuildJob
            steps:
              - script: echo "Building..."
```

### Variable Templates

Centralize environment-specific variables:

**Template: `templates/variables-nonprod.yml`**

```yaml
variables:
  - name: azureRegion
    value: "westeurope"
  - name: companyName
    value: "ensono"
  - name: projectName
    value: "data"
  - name: resourceGroupSuffix
    value: "nonprod"
  - name: enablePrivateNetworks
    value: false
  - group: "ensono-data-euw-data-nonprod-infra"
```

**Consuming Pipeline:**

```yaml
variables:
  - template: templates/variables-nonprod.yml

stages:
  - stage: Deploy
    jobs:
      - job: DeployInfra
        variables:
          rgName: "$(companyName)-$(projectName)-$(azureRegion)-$(resourceGroupSuffix)"
```

---

## Task Reproducibility with eirctl

### The eirctl Philosophy

**Core Principle**: Every task executed in Azure Pipelines should be reproducible locally using eirctl. This ensures:

- **Consistency**: Same commands run in CI/CD and locally
- **Debugging**: Developers can troubleshoot pipeline issues locally
- **Offline Development**: Work without cloud resources
- **Faster Feedback**: Test changes before pushing to the pipeline

### eirctl Integration Pattern

#### 1. Define Tasks in `eirctl.yaml`

```yaml
# eirctl.yaml
import:
  - ./build/eirctl/contexts.yaml
  - ./build/eirctl/tasks.yaml

pipelines:
  # Infrastructure deployment
  infrastructure:
    - task: infra:init
    - task: infra:vars
      depends_on: infra:init
    - task: infra:plan
      depends_on: infra:init
    - task: infra:apply
      depends_on: infra:plan

  # Linting
  lint:
    - task: lint:yaml
    - task: lint:terraform:validate
```

#### 2. Define Tasks in `build/eirctl/tasks.yaml`

```yaml
# build/eirctl/tasks.yaml
tasks:
  infra:init:
    context: powershell
    description: Initialise Terraform for Azure
    command: |
      Invoke-Terraform -Init -backend "$env:TF_BACKEND_INIT" -Path $env:TF_FILE_LOCATION -Debug
      Invoke-Terraform -Workspace -Arguments $env:ENV_NAME -Path $env:TF_FILE_LOCATION -Debug
      chown -R $env:USER_ID $env:TF_FILE_LOCATION/.terraform
      chgrp -R $env:USER_GROUP_ID $env:TF_FILE_LOCATION/.terraform

  infra:plan:
    context: powershell
    description: Plan Terraform
    command:
      - Invoke-Terraform -Plan -Path $env:TF_FILE_LOCATION -Arguments "-input=false","-out=`"deploy.tfplan`""

  infra:apply:
    context: powershell
    description: Apply Terraform Plan
    command: |
      Push-Location $env:TF_FILE_LOCATION
      Invoke-Terraform -Apply -Path deploy.tfplan -Debug
      $output_path = "/eirctl/outputs"
      if (Test-Path -Path $output_path) {
        chown -R $env:USER_ID $output_path
        chgrp -R $env:USER_GROUP_ID $output_path
      }

  lint:yaml:
    context: powershell
    description: Perform YAML linting
    command:
      - Invoke-YamlLint -FailOnWarnings $False
```

#### 3. Execute eirctl in Azure Pipelines

**Pattern 1: Direct Pipeline Execution**

```yaml
steps:
  - template: templates/install-eirctl.yml
    parameters:
      EirctlVersion: "v0.9.6"

  - task: Bash@3
    displayName: "Run eirctl: Infrastructure Deployment"
    inputs:
      targetType: "inline"
      script: |
        eirctl run infrastructure
    env:
      TF_BACKEND_INIT: $(tf_backend_init)
      TF_FILE_LOCATION: $(System.DefaultWorkingDirectory)/deploy/terraform/infra
      ENV_NAME: $(env_name)
      ARM_CLIENT_ID: $(arm_client_id)
      ARM_CLIENT_SECRET: $(arm_client_secret)
      ARM_TENANT_ID: $(arm_tenant_id)
      ARM_SUBSCRIPTION_ID: $(arm_subscription_id)
```

**Pattern 2: Staged Execution for Granular Control**

```yaml
stages:
  - stage: TerraformPlan
    displayName: "Terraform Plan"
    jobs:
      - job: Plan
        steps:
          - template: templates/install-eirctl.yml

          - task: Bash@3
            displayName: "Terraform Init"
            inputs:
              targetType: "inline"
              script: eirctl run infra:init

          - task: Bash@3
            displayName: "Generate TF Variables"
            inputs:
              targetType: "inline"
              script: eirctl run infra:vars

          - task: Bash@3
            displayName: "Terraform Plan"
            inputs:
              targetType: "inline"
              script: eirctl run infra:plan

          - task: PublishPipelineArtifact@1
            displayName: "Publish Terraform Plan"
            inputs:
              targetPath: "$(System.DefaultWorkingDirectory)/deploy/terraform/infra/deploy.tfplan"
              artifactName: "terraform-plan"

  - stage: TerraformApply
    displayName: "Terraform Apply"
    dependsOn: TerraformPlan
    condition: succeeded()
    jobs:
      - deployment: ApplyPlan
        environment: "nonprod"
        strategy:
          runOnce:
            deploy:
              steps:
                - template: templates/install-eirctl.yml

                - task: DownloadPipelineArtifact@2
                  displayName: "Download Terraform Plan"
                  inputs:
                    artifactName: "terraform-plan"
                    targetPath: "$(System.DefaultWorkingDirectory)/deploy/terraform/infra"

                - task: Bash@3
                  displayName: "Terraform Apply"
                  inputs:
                    targetType: "inline"
                    script: eirctl run infra:apply
```

### Local Development with eirctl

Developers can replicate pipeline behavior locally:

```bash
# Generate local environment file
eirctl run local:envfile:bash

# Source the environment variables
source local/envfile_infra.bash

# Run the same commands as the pipeline
eirctl run infrastructure

# Or run individual tasks
eirctl run infra:init
eirctl run infra:plan
eirctl run infra:apply
```

### eirctl Best Practices

1. **Task Granularity**: Create focused, single-purpose tasks
2. **Environment Variables**: Use environment variables for configuration, not hardcoded values
3. **Idempotent Commands**: Tasks should be safe to run multiple times
4. **Error Handling**: Exit with non-zero code on failure
5. **Documentation**: Include meaningful descriptions for each task
6. **Dependencies**: Use `depends_on` to establish clear task order
7. **Contexts**: Use appropriate contexts (bash, powershell, docker) for each task

---

## Triggers and CI/CD Automation

### Continuous Integration (CI) Triggers

#### Branch-Based Triggers

```yaml
trigger:
  branches:
    include:
      - main
      - feature/*
      - release/*
    exclude:
      - feature/experimental/*
  paths:
    include:
      - "deploy/terraform/**"
      - "de_workloads/**"
      - "build/azdo/**"
    exclude:
      - "**/*.md"
      - "docs/**"
      - ".github/**"
  tags:
    include:
      - v*
    exclude:
      - v*-preview
```

**Best Practices**:

- Use explicit `include` and `exclude` for clarity
- Use path filters to avoid unnecessary builds
- Exclude documentation changes from infrastructure pipelines
- Use wildcards for branch patterns (`feature/*`)

#### Disable Implicit Triggers

For pipelines triggered manually or by other pipelines:

```yaml
trigger: none

pr: none
```

### Pull Request (PR) Triggers

#### GitHub Repository

```yaml
pr:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - "src/**"
      - "tests/**"
    exclude:
      - "**/*.md"
  drafts: false # Don't trigger on draft PRs
```

#### Azure Repos (Branch Policies)

For Azure Repos, configure PR validation via branch policies:

1. Navigate to **Repos** > **Branches**
2. Select branch policies for `main`
3. Add **Build Validation** policy
4. Select the pipeline to run on PRs
5. Configure path filters if needed

```yaml
# In pipeline YAML (optional, branch policy takes precedence)
pr:
  branches:
    include:
      - main
```

### Scheduled Triggers

```yaml
schedules:
  - cron: "0 2 * * *" # Run at 2 AM UTC daily
    displayName: "Nightly Build"
    branches:
      include:
        - main
    always: false # Only run if there are changes

  - cron: "0 0 * * 0" # Run at midnight UTC on Sundays
    displayName: "Weekly Full Deployment"
    branches:
      include:
        - main
    always: true # Always run, even without changes
```

**Cron Syntax**: UTC time zone

- `* * * * *` = minute hour day month dayOfWeek
- Use [crontab.guru](https://crontab.guru/) for validation

### Pipeline Triggers (Downstream Pipelines)

Trigger one pipeline when another completes:

```yaml
resources:
  pipelines:
    - pipeline: upstream-build
      source: "infrastructure-deployment"
      trigger:
        branches:
          include:
            - main
            - release/*
        stages:
          - Deploy_Prod # Only trigger if this stage succeeds

stages:
  - stage: IntegrationTest
    jobs:
      - job: RunTests
        steps:
          - script: |
              echo "Upstream pipeline $(resources.pipeline.upstream-build.runID) completed"
              echo "Triggering branch: $(resources.pipeline.upstream-build.sourceBranch)"
```

### Combining Triggers

**Anti-Pattern**: Combining CI and pipeline triggers can cause duplicate runs

```yaml
# This will trigger twice: once on commit, once on upstream completion
trigger:
  branches:
    include:
      - main

resources:
  pipelines:
    - pipeline: upstream
      source: "build-pipeline"
      trigger:
        branches:
          include:
            - main
```

**Solution**: Disable one trigger type

```yaml
# Only trigger from upstream pipeline
trigger: none

resources:
  pipelines:
    - pipeline: upstream
      source: "build-pipeline"
      trigger:
        branches:
          include:
            - main
```

---

## Approvals and Deployment Gates

### Environment-Based Approvals

Define approval requirements for environments:

1. Navigate to **Pipelines** > **Environments**
2. Create or select environment (e.g., `prod`)
3. Select **Approvals and checks**
4. Add **Approvals** check

**Pipeline Configuration:**

```yaml
stages:
  - stage: Deploy_Prod
    displayName: "Deploy to Production"
    jobs:
      - deployment: DeployInfrastructure
        environment: "prod" # Approval configured on environment
        strategy:
          runOnce:
            deploy:
              steps:
                - template: templates/terraform-deploy.yml
```

### Manual Validation Task

Pause pipeline for manual validation:

```yaml
stages:
  - stage: PreProductionValidation
    displayName: "Pre-Production Validation"
    jobs:
      - job: WaitForValidation
        displayName: "Wait for Manual Validation"
        pool: server # Agentless job
        steps:
          - task: ManualValidation@0
            timeoutInMinutes: 1440 # 24 hours
            inputs:
              notifyUsers: |
                user1@example.com
                user2@example.com
              instructions: |
                Please verify the following before approving:
                1. Smoke tests passed in staging
                2. Security scan results reviewed
                3. Change Advisory Board (CAB) approval obtained
                4. Backout plan documented
              onTimeout: "reject"

  - stage: Deploy_Prod
    dependsOn: PreProductionValidation
    condition: succeeded('PreProductionValidation')
    jobs:
      - deployment: DeployInfrastructure
        environment: "prod"
```

### Deployment Gates

Configure automated checks before and after deployments:

#### Pre-Deployment Gates

1. Navigate to **Pipelines** > **Releases** (Classic) or configure in YAML
2. Select **Pre-deployment conditions**
3. Enable **Gates**
4. Add gate types:
   - **Query Work Items**: Ensure no P0 bugs
   - **Azure Function**: Custom validation logic
   - **Invoke REST API**: Check external system status
   - **Query Azure Monitor**: Check for alerts

**Example: Query Work Items Gate**

```yaml
# Note: Gates are primarily a Classic release feature
# For YAML pipelines, use checks on environments

# Environment check configuration (via UI):
# - Add "Query Work Items" check
# - Query: Type = Bug AND State <> Closed AND Priority = 0
# - Pass on zero results
```

#### Invoke REST API Check

For YAML pipelines, use the **Invoke REST API** check on environments:

1. Navigate to **Environment** > **Approvals and checks**
2. Add **Invoke REST API** check
3. Configure:
   - **Method**: GET
   - **URL**: `https://api.example.com/health`
   - **Success criteria**: Response body equals `{"status": "healthy"}`
   - **Retry interval**: 5 minutes
   - **Timeout**: 30 minutes

### Combining Approvals and Gates

**Best Practice Order**:

1. **Pre-Deployment Gates**: Automated checks (work items, monitoring, security scans)
2. **Pre-Deployment Approvals**: Manual approval after gates pass
3. **Deployment**: Execute deployment tasks
4. **Post-Deployment Gates**: Verify deployment health
5. **Post-Deployment Approvals**: Sign-off after verification

```yaml
stages:
  - stage: Deploy_Prod
    jobs:
      - deployment: DeployToProduction
        environment: "prod" # Has approvals and checks configured
        strategy:
          runOnce:
            preDeploy:
              steps:
                - script: echo "Pre-deployment checks and approvals completed"

            deploy:
              steps:
                - template: templates/terraform-deploy.yml

            routeTraffic:
              steps:
                - script: echo "Routing traffic to new deployment"

            postRouteTraffic:
              steps:
                - task: ManualValidation@0
                  inputs:
                    instructions: "Verify production deployment health before completing"
```

---

## Performance Optimization

### Parallel Jobs

Execute independent jobs concurrently:

```yaml
jobs:
  - job: BuildLinux
    pool:
      vmImage: "ubuntu-latest"
    steps:
      - script: echo "Building for Linux"

  - job: BuildWindows
    pool:
      vmImage: "windows-latest"
    steps:
      - script: echo "Building for Windows"

  - job: BuildMac
    pool:
      vmImage: "macOS-latest"
    steps:
      - script: echo "Building for macOS"
```

All three jobs run simultaneously, reducing total pipeline time.

### Matrix Strategy

Run the same job with different configurations:

```yaml
jobs:
  - job: TestMultipleVersions
    strategy:
      matrix:
        Python39:
          python.version: "3.9"
          spark.version: "3.3"
        Python310:
          python.version: "3.10"
          spark.version: "3.4"
        Python311:
          python.version: "3.11"
          spark.version: "3.4"
      maxParallel: 3
    steps:
      - task: UsePythonVersion@0
        inputs:
          versionSpec: "$(python.version)"

      - script: |
          pip install pyspark==$(spark.version)
          pytest tests/
```

### Parallel Test Execution

Split tests across multiple agents:

```yaml
jobs:
  - job: ParallelTests
    strategy:
      parallel: 4 # Split across 4 agents
    steps:
      - task: Bash@3
        inputs:
          targetType: "inline"
          script: |
            # System.JobPositionInPhase = 1, 2, 3, or 4
            # System.TotalJobsInPhase = 4
            echo "Running tests for partition $(System.JobPositionInPhase) of $(System.TotalJobsInPhase)"
            pytest tests/ --splits $(System.TotalJobsInPhase) --group $(System.JobPositionInPhase)
```

### Caching Dependencies

Cache package dependencies to avoid repeated downloads:

```yaml
steps:
  - task: Cache@2
    displayName: "Cache: Python packages"
    inputs:
      key: 'python | "$(Agent.OS)" | requirements.txt'
      restoreKeys: |
        python | "$(Agent.OS)"
        python
      path: $(Pipeline.Workspace)/.pip

  - task: Bash@3
    displayName: "Install: Python dependencies"
    inputs:
      targetType: "inline"
      script: |
        python -m pip install --cache-dir $(Pipeline.Workspace)/.pip -r requirements.txt

  # For NuGet packages
  - task: Cache@2
    displayName: "Cache: NuGet packages"
    inputs:
      key: 'nuget | "$(Agent.OS)" | **/packages.lock.json'
      restoreKeys: |
        nuget | "$(Agent.OS)"
      path: $(Pipeline.Workspace)/.nuget/packages

  - task: NuGetCommand@2
    condition: ne(variables['CacheRestored'], 'true')
    inputs:
      command: "restore"
      restoreSolution: "**/*.sln"

  # For Terraform providers
  - task: Cache@2
    displayName: "Cache: Terraform providers"
    inputs:
      key: 'terraform | "$(Agent.OS)" | deploy/terraform/**/.terraform.lock.hcl'
      restoreKeys: |
        terraform | "$(Agent.OS)"
      path: $(Pipeline.Workspace)/.terraform.d/plugin-cache
```

**Performance Impact**:

- First run: Downloads all dependencies (~2-5 minutes)
- Subsequent runs: Restores from cache (~10-30 seconds)

### Choose Appropriate Agents

**Microsoft-Hosted Agents**:

- **Standard**: 2 vCPUs, 7 GB RAM
- **Advantages**: No maintenance, always up-to-date, parallel capacity
- **Disadvantages**: Slower for large downloads, no persistent cache

**Self-Hosted Agents**:

- **Custom specifications**: Choose CPU/RAM/disk
- **Advantages**: Faster builds, persistent cache, custom tools, network locality
- **Disadvantages**: Maintenance overhead, patching required

```yaml
jobs:
  - job: FastBuild
    pool:
      name: "ensono-data-euw-hub-agent-pool" # Self-hosted pool
      demands:
        - agent.os -equals Linux
        - terraform -equals true
    steps:
      - script: echo "Running on optimized self-hosted agent"
```

### Optimize Build Steps

1. **Fail Fast**: Run quick validation steps first
2. **Conditional Steps**: Skip unnecessary work

```yaml
steps:
  # Fast validation steps first
  - task: Bash@3
    displayName: "Validate: YAML syntax"
    inputs:
      targetType: "inline"
      script: eirctl run lint:yaml

  - task: Bash@3
    displayName: "Validate: Terraform format"
    inputs:
      targetType: "inline"
      script: eirctl run lint:terraform:format

  # Expensive steps only if validation passes
  - task: Bash@3
    displayName: "Build: Docker images"
    condition: succeeded()
    inputs:
      targetType: "inline"
      script: docker build -t myapp:latest .
```

---

## Variables and Parameters

### Variable Precedence

Azure Pipelines variables have a specific precedence order (highest to lowest):

1. Variables set by pipeline tasks (runtime)
2. Variables set at job level
3. Variables set at stage level
4. Variables set at pipeline (root) level
5. Variables set in the pipeline UI
6. Variables from variable groups

### Runtime Parameters vs. Variables

**Parameters**:

- Set at queue time
- Type-safe (string, number, boolean, object)
- Cannot be modified during pipeline execution
- Visible in the pipeline run UI

```yaml
parameters:
  - name: deployEnvironment
    type: string
    displayName: "Target Environment"
    default: "dev"
    values:
      - dev
      - qa
      - uat
      - prod

  - name: enableDebug
    type: boolean
    displayName: "Enable Debug Logging"
    default: false

variables:
  environment: "${{ parameters.deployEnvironment }}"
  isDebugEnabled: "${{ parameters.enableDebug }}"
```

**Variables**:

- Can be set at various levels
- Can be modified during execution
- Support complex expressions

```yaml
variables:
  - name: buildConfiguration
    value: "Release"

  - name: azureSubscription
    ${{ if eq(parameters.deployEnvironment, 'prod') }}:
      value: "azure-prod-subscription"
    ${{ else }}:
      value: "azure-nonprod-subscription"

  - group: "common-variables"
  - group: ${{ format('env-{0}', parameters.deployEnvironment) }}
```

### Variable Groups

Organize related variables in groups:

1. Navigate to **Pipelines** > **Library**
2. Create variable group (e.g., `ensono-data-euw-data-nonprod-infra`)
3. Link to Azure Key Vault (optional)
4. Define variables

**Naming Convention**:

```
{company}-{project}-{region}-{component}-{environment}-{stage}

Examples:
- ensono-data-euw-data-nonprod-infra
- ensono-data-euw-data-nonprod-databricks
- ensono-data-euw-data-prod-infra
```

**Consume in Pipeline**:

```yaml
variables:
  - group: "ensono-data-euw-data-nonprod-infra"
  - group: "ensono-data-euw-data-nonprod-databricks"

steps:
  - script: |
      echo "Storage account: $(storage_account_name)"
      echo "Key vault: $(key_vault_name)"
```

### Conditional Variables

```yaml
variables:
  - name: resourceGroupName
    ${{ if eq(parameters.environment, 'prod') }}:
      value: "ensono-data-euw-data-prod"
    ${{ else }}:
      value: "ensono-data-euw-data-$(parameters.environment)"

  - name: enablePrivateNetworks
    ${{ if eq(parameters.environment, 'prod') }}:
      value: true
    ${{ else }}:
      value: false
```

### Output Variables

Pass variables between jobs/stages:

```yaml
jobs:
  - job: BuildJob
    steps:
      - task: Bash@3
        name: SetVersion
        inputs:
          targetType: "inline"
          script: |
            VERSION="1.2.3-$(Build.BuildId)"
            echo "##vso[task.setvariable variable=appVersion;isOutput=true]$VERSION"

  - job: DeployJob
    dependsOn: BuildJob
    variables:
      appVersion: $[ dependencies.BuildJob.outputs['SetVersion.appVersion'] ]
    steps:
      - script: echo "Deploying version $(appVersion)"
```

**Cross-Stage Variables**:

```yaml
stages:
  - stage: Build
    jobs:
      - job: BuildApp
        steps:
          - task: Bash@3
            name: SetBuildInfo
            inputs:
              targetType: "inline"
              script: |
                echo "##vso[task.setvariable variable=buildNumber;isOutput=true]$(Build.BuildId)"

  - stage: Deploy
    dependsOn: Build
    variables:
      buildNumber: $[ stageDependencies.Build.BuildApp.outputs['SetBuildInfo.buildNumber'] ]
    jobs:
      - job: DeployApp
        steps:
          - script: echo "Deploying build $(buildNumber)"
```

### Secret Variables

**Mark variables as secret in variable groups**:

- Secrets are masked in logs
- Secrets are encrypted at rest
- Cannot be accessed by forked PRs

```yaml
variables:
  - group: "secure-variables" # Contains secret variables

steps:
  - task: AzureCLI@2
    displayName: "Use secret"
    inputs:
      azureSubscription: "$(service_connection_name)"
      scriptType: "bash"
      scriptLocation: "inlineScript"
      inlineScript: |
        # $(database_password) is masked in logs
        az sql db create --name mydb --server myserver --admin-password $(database_password)
```

---

## Testing Strategies

### Unit Testing

Run unit tests early in the pipeline:

```yaml
stages:
  - stage: Test
    displayName: "Unit and Integration Tests"
    jobs:
      - job: UnitTests
        displayName: "Python Unit Tests"
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: "3.10"

          - task: Bash@3
            displayName: "Install: Dependencies"
            inputs:
              targetType: "inline"
              script: |
                pip install poetry
                poetry install

          - task: Bash@3
            displayName: "Test: Unit tests"
            inputs:
              targetType: "inline"
              script: |
                poetry run pytest tests/unit \
                  --junitxml=$(System.DefaultWorkingDirectory)/test-results/unit-tests.xml \
                  --cov=src \
                  --cov-report=xml:$(System.DefaultWorkingDirectory)/coverage/coverage.xml \
                  --cov-report=html:$(System.DefaultWorkingDirectory)/coverage/html

          - task: PublishTestResults@2
            displayName: "Publish: Test results"
            condition: always()
            inputs:
              testResultsFormat: "JUnit"
              testResultsFiles: "**/test-results/*.xml"
              failTaskOnFailedTests: true

          - task: PublishCodeCoverageResults@1
            displayName: "Publish: Code coverage"
            condition: always()
            inputs:
              codeCoverageTool: "Cobertura"
              summaryFileLocation: "$(System.DefaultWorkingDirectory)/coverage/coverage.xml"
              reportDirectory: "$(System.DefaultWorkingDirectory)/coverage/html"
```

### Integration Testing

Test with external dependencies:

```yaml
jobs:
  - job: IntegrationTests
    displayName: "Integration Tests"
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: testpass
        ports:
          - 5432:5432
    steps:
      - task: Bash@3
        displayName: "Test: Integration tests"
        inputs:
          targetType: "inline"
          script: |
            export DATABASE_URL="postgresql://postgres:testpass@localhost:5432/testdb"
            poetry run pytest tests/integration \
              --junitxml=$(System.DefaultWorkingDirectory)/test-results/integration-tests.xml
```

### End-to-End Testing

Deploy to test environment and run E2E tests:

```yaml
stages:
  - stage: E2E_Tests
    displayName: "End-to-End Tests"
    dependsOn: Deploy_Test
    jobs:
      - job: DeployTestData
        steps:
          - task: Bash@3
            displayName: "Setup: Test data"
            inputs:
              targetType: "inline"
              script: |
                eirctl run deworkload:Testing

      - job: RunE2ETests
        dependsOn: DeployTestData
        steps:
          - task: Bash@3
            displayName: "Test: End-to-end scenarios"
            inputs:
              targetType: "inline"
              script: |
                poetry run pytest tests/end_to_end \
                  --env=test \
                  --junitxml=$(System.DefaultWorkingDirectory)/test-results/e2e-tests.xml
```

### Data Quality Testing

For data engineering workloads:

```yaml
jobs:
  - job: DataQualityTests
    displayName: "Data Quality Validation"
    steps:
      - task: Bash@3
        displayName: "Test: Data quality checks"
        inputs:
          targetType: "inline"
          script: |
            # Run stacks-data data quality checks
            python -m stacks.data.data_quality_main \
              --config de_workloads/processing/silver_movies_example_with_data_quality/config/data_quality_config.yaml \
              --output $(System.DefaultWorkingDirectory)/dq-results/

      - task: PublishPipelineArtifact@1
        displayName: "Publish: DQ results"
        inputs:
          targetPath: "$(System.DefaultWorkingDirectory)/dq-results"
          artifactName: "data-quality-results"
```

### Test Result Gating

Fail the pipeline if test metrics don't meet thresholds:

```yaml
steps:
  - task: PublishTestResults@2
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "**/test-results/*.xml"
      failTaskOnFailedTests: true
      testRunTitle: "Unit Tests"

  - task: PublishCodeCoverageResults@1
    inputs:
      codeCoverageTool: "Cobertura"
      summaryFileLocation: "$(System.DefaultWorkingDirectory)/coverage/coverage.xml"

  - task: BuildQualityChecks@8
    displayName: "Quality Gate: Code coverage"
    inputs:
      checkCoverage: true
      coverageFailOption: "fixed"
      coverageThreshold: "80"
      coverageType: "lines"
```

---

## Monitoring and Observability

### Pipeline Analytics

Azure DevOps provides built-in analytics:

1. **Pipeline run history**: View success/failure trends
2. **Duration trends**: Identify performance regressions
3. **Test analytics**: Track test pass rates and flakiness

### Custom Logging

Implement structured logging in pipeline tasks:

```yaml
steps:
  - task: Bash@3
    displayName: "Structured Logging Example"
    inputs:
      targetType: "inline"
      script: |
        # Log levels: debug, warning, error
        echo "##[debug]Detailed debug information"
        echo "##[warning]Something might be wrong"
        echo "##[error]An error occurred"

        # Section grouping
        echo "##[group]Deploying infrastructure"
        eirctl run infra:apply
        echo "##[endgroup]"

        # Set pipeline result
        echo "##vso[task.complete result=SucceededWithIssues;]Deployment completed with warnings"
```

### Publish Pipeline Artifacts

Save important files for debugging:

```yaml
steps:
  - task: Bash@3
    displayName: "Run Terraform"
    inputs:
      targetType: "inline"
      script: eirctl run infra:apply
    continueOnError: true

  - task: PublishPipelineArtifact@1
    displayName: "Publish: Terraform logs"
    condition: always()
    inputs:
      targetPath: "$(System.DefaultWorkingDirectory)/deploy/terraform/infra"
      artifactName: "terraform-logs-$(System.JobId)"
      publishLocation: "pipeline"
```

### Deployment Logging

Track deployments for audit and troubleshooting:

```yaml
stages:
  - stage: Deploy_Prod
    jobs:
      - deployment: DeployInfrastructure
        environment: "prod"
        strategy:
          runOnce:
            deploy:
              steps:
                - task: Bash@3
                  displayName: "Log: Deployment start"
                  inputs:
                    targetType: "inline"
                    script: |
                      echo "Deployment started at $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                      echo "Build ID: $(Build.BuildId)"
                      echo "Build Number: $(Build.BuildNumber)"
                      echo "Triggered by: $(Build.RequestedFor)"
                      echo "Source branch: $(Build.SourceBranch)"
                      echo "Commit: $(Build.SourceVersion)"

                - template: templates/terraform-deploy.yml

                - task: Bash@3
                  displayName: "Log: Deployment complete"
                  condition: always()
                  inputs:
                    targetType: "inline"
                    script: |
                      echo "Deployment completed at $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                      echo "Status: $(Agent.JobStatus)"
```

### Integration with Azure Application Insights

Send pipeline metrics to Application Insights:

```yaml
steps:
  - task: Bash@3
    displayName: "Send telemetry to App Insights"
    inputs:
      targetType: "inline"
      script: |
        INSTRUMENTATION_KEY="$(app_insights_key)"
        DEPLOYMENT_ID="$(Build.BuildId)"
        ENVIRONMENT="prod"

        # Send custom event
        curl -X POST https://dc.services.visualstudio.com/v2/track \
          -H "Content-Type: application/json" \
          -d '{
            "name": "Microsoft.ApplicationInsights.Event",
            "time": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
            "iKey": "'$INSTRUMENTATION_KEY'",
            "data": {
              "baseType": "EventData",
              "baseData": {
                "name": "DeploymentCompleted",
                "properties": {
                  "deploymentId": "'$DEPLOYMENT_ID'",
                  "environment": "'$ENVIRONMENT'",
                  "pipeline": "$(Build.DefinitionName)"
                }
              }
            }
          }'
```

---

## Project-Specific Guidelines

### Stacks Azure Data Platform Structure

#### Pipeline Organization

```
build/azdo/
├── pipeline-full-deployment.yml      # Main deployment pipeline
├── pipeline-full-teardown.yml        # Environment teardown
├── pipeline-infra-private.yml        # Private networking
├── pipeline-networking.yml           # Network infrastructure
├── pipeline-databricks.yml           # Databricks configuration
├── variables.yml                     # Shared variables
├── stages/
│   └── infra.yml                     # Infrastructure stage template
└── templates/
    ├── install-eirctl.yml            # eirctl installation
    ├── terraform-deploy.yml          # Terraform deployment template
    ├── terraform-networking.yml      # Networking deployment template
    └── upload.yml                    # Artifact upload template
```

#### DE Workload Pipelines

Each data engineering workload has its own pipeline:

```
de_workloads/
├── ingest/
│   └── ingest_azure_sql_example/
│       ├── de-ingest-ado-pipeline.yml
│       ├── config/
│       ├── data_factory/
│       ├── spark_jobs/
│       └── tests/
└── processing/
    └── silver_movies_example/
        ├── de-process-ado-pipeline.yml
        ├── config/
        ├── data_factory/
        ├── spark_jobs/
        └── tests/
```

**Workload Pipeline Pattern**:

```yaml
name: "$(Build.SourceBranchName)-ingest-azure-sql"

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - "de_workloads/ingest/ingest_azure_sql_example/**"

variables:
  - template: ../../build/azdo/variables.yml
  - group: "ensono-data-euw-data-nonprod-databricks"

stages:
  - stage: Build
    jobs:
      - job: BuildSparkJob
        steps:
          - template: ../../build/azdo/templates/install-eirctl.yml

          - task: Bash@3
            displayName: "Build: Spark job"
            inputs:
              targetType: "inline"
              script: |
                cd de_workloads/ingest/ingest_azure_sql_example
                poetry build

  - stage: Test
    dependsOn: Build
    jobs:
      - job: UnitTests
        steps:
          - task: Bash@3
            displayName: "Test: Unit tests"
            inputs:
              targetType: "inline"
              script: |
                cd de_workloads/ingest/ingest_azure_sql_example
                poetry run pytest tests/unit

  - stage: Deploy
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployADF
        environment: "nonprod"
        steps:
          - template: ../../build/azdo/templates/terraform-deploy.yml
            parameters:
              tfWorkingDirectory: "de_workloads/ingest/ingest_azure_sql_example/data_factory"
```

### Variable Group Naming

Follow the established naming convention:

```
{company}-{project}-{region}-{component}-{environment}-{stage}

Examples:
✅ ensono-data-euw-data-nonprod-infra
✅ ensono-data-euw-data-prod-databricks
✅ ensono-data-euw-data-nonprod-network

❌ my-variables
❌ dev-vars
❌ production-settings
```

### Path-Based Triggers

Use path filters to avoid triggering unrelated pipelines:

```yaml
# Infrastructure pipeline
trigger:
  paths:
    include:
      - 'deploy/terraform/infra/**'
      - 'build/azdo/pipeline-full-deployment.yml'
    exclude:
      - '**/*.md'

# Networking pipeline
trigger:
  paths:
    include:
      - 'deploy/terraform/networking/**'
      - 'build/azdo/pipeline-networking.yml'

# DE workload pipeline
trigger:
  paths:
    include:
      - 'de_workloads/ingest/ingest_azure_sql_example/**'
```

### Multi-Environment Deployment

Use parameters and templates for consistent multi-environment deployments:

```yaml
parameters:
  - name: environment
    type: string
    default: nonprod
    values:
      - nonprod
      - prod

  - name: env_name
    type: string
    default: dev
    values:
      - dev
      - qa
      - uat
      - prod

variables:
  - name: resourceGroupName
    value: "ensono-data-euw-data-${{ parameters.env_name }}"

  - name: variableGroup
    ${{ if eq(parameters.environment, 'prod') }}:
      value: "ensono-data-euw-data-prod-infra"
    ${{ else }}:
      value: "ensono-data-euw-data-nonprod-infra"

stages:
  - template: templates/terraform-deploy.yml
    parameters:
      stageName: "Deploy_${{ parameters.env_name }}"
      environment: "${{ parameters.environment }}"
      variableGroup: $(variableGroup)
```

---

## Common Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Not Using eirctl

**Bad**:

```yaml
steps:
  - task: Bash@3
    inputs:
      targetType: "inline"
      script: |
        cd deploy/terraform/infra
        terraform init -backend-config="storage_account_name=$(storage_account_name)"
        terraform workspace select dev
        terraform plan -out=deploy.tfplan
        terraform apply deploy.tfplan
```

**Good**:

```yaml
steps:
  - template: templates/install-eirctl.yml

  - task: Bash@3
    inputs:
      targetType: "inline"
      script: eirctl run infrastructure
```

**Why**: eirctl ensures reproducibility, consistency, and easier debugging.

### ❌ Anti-Pattern 2: Hardcoding Values

**Bad**:

```yaml
variables:
  resourceGroupName: "ensono-data-euw-data-dev"
  storageAccountName: "ensonodataeuwdev"
```

**Good**:

```yaml
variables:
  - group: "ensono-data-euw-data-nonprod-infra"

  - name: resourceGroupName
    value: "$(company_name)-$(project_name)-$(azure_region)-data-$(env_name)"
```

### ❌ Anti-Pattern 3: No Error Handling

**Bad**:

```yaml
steps:
  - script: terraform apply -auto-approve
  - script: deploy-app.sh
```

**Good**:

```yaml
steps:
  - task: Bash@3
    displayName: "Terraform Apply"
    inputs:
      targetType: "inline"
      script: eirctl run infra:apply
    continueOnError: false

  - task: Bash@3
    displayName: "Deploy Application"
    condition: succeeded()
    inputs:
      targetType: "inline"
      script: ./deploy-app.sh
```

### ❌ Anti-Pattern 4: Overly Broad Triggers

**Bad**:

```yaml
trigger:
  - "*" # Triggers on all branches
```

**Good**:

```yaml
trigger:
  branches:
    include:
      - main
      - release/*
  paths:
    include:
      - "deploy/terraform/**"
    exclude:
      - "**/*.md"
```

### ❌ Anti-Pattern 5: No Approval for Production

**Bad**:

```yaml
stages:
  - stage: Deploy_Prod
    jobs:
      - job: DeployInfra
        steps:
          - script: terraform apply -auto-approve
```

**Good**:

```yaml
stages:
  - stage: Deploy_Prod
    jobs:
      - deployment: DeployInfra
        environment: "prod" # Requires approval
        strategy:
          runOnce:
            deploy:
              steps:
                - template: templates/terraform-deploy.yml
```

---

## Checklist for New Pipelines

Use this checklist when creating new pipelines:

### Planning

- [ ] Define pipeline purpose and scope
- [ ] Identify required environments (dev, qa, prod)
- [ ] List dependencies (other pipelines, services)
- [ ] Determine approval requirements

### Configuration

- [ ] Use descriptive pipeline name
- [ ] Configure appropriate triggers (CI, PR, scheduled)
- [ ] Set up path filters to avoid unnecessary runs
- [ ] Create parameter definitions with validation

### Security

- [ ] Use variable groups for secrets
- [ ] Link variable groups to Azure Key Vault
- [ ] Configure service connections with least privilege
- [ ] Set up environment-based approvals
- [ ] Enable shell parameter validation

### Structure

- [ ] Use multi-stage pipeline structure
- [ ] Define explicit stage dependencies
- [ ] Use templates for reusable components
- [ ] Implement eirctl for task reproducibility

### Testing

- [ ] Include unit test stage
- [ ] Add integration test stage (if applicable)
- [ ] Configure test result publication
- [ ] Set up code coverage reporting
- [ ] Define quality gates

### Deployment

- [ ] Use deployment jobs for environment tracking
- [ ] Configure pre-deployment approvals
- [ ] Set up deployment gates (if needed)
- [ ] Implement rollback strategy
- [ ] Add post-deployment validation

### Monitoring

- [ ] Publish pipeline artifacts for debugging
- [ ] Implement structured logging
- [ ] Configure failure notifications
- [ ] Set up deployment telemetry

### Documentation

- [ ] Add pipeline description
- [ ] Document parameters and variables
- [ ] Create runbook for manual interventions
- [ ] Update project documentation

---

## Additional Resources

### Microsoft Learn Documentation

- [Azure Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [YAML Schema Reference](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/)
- [Pipeline Security Best Practices](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview)
- [Template Reference](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates)
- [Deployment Approvals and Gates](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/approvals/)

### Project Documentation

- [Stacks Azure Data Platform README](../README.md)
- [Security and Compliance Instructions](../.github/copilot-security-instructions.md)
- [Troubleshooting Network Deletion](./troubleshooting-network-deletion.md)
- [Terraform State Key Standardization](./terraform-state-key-standardization.md)

### eirctl Resources

- [eirctl GitHub Repository](https://github.com/Ensono/eirctl)
- [eirctl Configuration](../eirctl.yaml)
- [Task Definitions](../build/eirctl/tasks.yaml)
- [Context Definitions](../build/eirctl/contexts.yaml)

---

## Conclusion

Following these best practices ensures that Azure Pipelines for the Stacks Azure Data Platform are:

- **Secure**: Secrets managed properly, approvals enforced
- **Reproducible**: eirctl enables local execution
- **Efficient**: Parallelism and caching optimize performance
- **Maintainable**: Templates promote consistency and reduce duplication
- **Observable**: Comprehensive logging and monitoring
- **Compliant**: Meets security and regulatory requirements

Remember: **Every task should be reproducible locally using eirctl before adding it to a pipeline.**

For questions or improvements to this guide, please open an issue or submit a pull request.
