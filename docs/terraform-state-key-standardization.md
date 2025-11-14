# Terraform State Key Standardization

**Document Version**: 1.0
**Date**: November 14, 2025
**Author**: GitHub Copilot (AI Assistant)
**Status**: Complete

## Executive Summary

This document describes the comprehensive work undertaken to standardize Terraform state key naming conventions across the Ensono Stacks Azure Data Platform project. The standardization ensures consistent state file organization, prevents state conflicts, and enables proper environment isolation.

## Table of Contents

1. [Background](#background)
2. [Problem Statement](#problem-statement)
3. [Solution Architecture](#solution-architecture)
4. [Naming Convention Components](#naming-convention-components)
5. [Implementation Patterns](#implementation-patterns)
6. [Changes Made](#changes-made)
7. [Validation and Testing](#validation-and-testing)
8. [Migration Guide](#migration-guide)

---

## Background

### What is Terraform State?

Terraform state files track the current state of infrastructure resources managed by Terraform. These files are critical for:

- Mapping configuration to real-world resources
- Tracking metadata and resource dependencies
- Performance optimization through caching
- Collaboration between team members

### Azure Backend Configuration

The Ensono Stacks project uses Azure Storage Account as the Terraform backend with the following structure:

```
Storage Account: stacksstatehjfis
Resource Group: stacks-terraform-state
Container: tfstate
State Files: key=<tf_state_key>
```

Each unique `tf_state_key` creates a separate state file blob in the storage container, enabling isolation between different:

- Environments (dev, qa, uat, prod)
- Components (networking, infrastructure, databricks)
- Workloads (data ingestion, processing pipelines)

---

## Problem Statement

### Issues Identified

Prior to standardization, the project suffered from several inconsistencies:

#### 1. **Inconsistent Naming Patterns**

```yaml
# Before - Mixed patterns found:
❌ $(company)-$(project)-$(domain)-networking          # Missing environment
❌ $(company)-$(project)-$(domain)-data                # Wrong component name
❌ $(company)-$(project)-$(domain)-network             # Inconsistent component name
❌ $(company)-$(project)-$(domain)-azdo                # Unclear component name
```

#### 2. **Project Variable Duplication**

```yaml
# Original configuration caused duplication:
company: ensono
project: data # ❌ WRONG - Should be "stacks"
domain: data # ✓ Correct

# Result: ensono-data-data-networking (duplicate "data")
```

#### 3. **Missing Environment Isolation**

Infrastructure state keys lacked environment identifiers, risking state conflicts between dev, qa, uat, and prod environments deploying to the same storage backend.

#### 4. **Template Parameter Inconsistencies**

Some pipelines used `$(environment)` (nonprod/prod) instead of `$(env_name)` (dev/qa/uat/prod) for state keys, causing incorrect state file targeting.

---

## Solution Architecture

### Design Principles

1. **Hierarchical Structure**: Keys follow a clear hierarchy from general to specific
2. **Environment Isolation**: Each environment maintains separate state files
3. **Component Clarity**: Component names clearly identify the infrastructure layer
4. **Consistency**: All infrastructure pipelines follow the same pattern
5. **Extensibility**: Pattern supports future components and workloads

### State Key Hierarchy

```
┌───────────────────────────────────────────────────────────┐
│  Azure Storage Account: stacksstatehjfis                  │
│  Container: tfstate                                       │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Infrastructure States (Environment-Specific)        │  │
│  │  - ensono-stacks-data-dev-networking                │  │
│  │  - ensono-stacks-data-dev-infra                     │  │
│  │  - ensono-stacks-data-dev-databricks                │  │
│  │  - ensono-stacks-data-qa-networking                 │  │
│  │  - ensono-stacks-data-qa-infra                      │  │
│  │  - ensono-stacks-data-qa-databricks                 │  │
│  │  ...                                                │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Data Workload States (Workload-Specific)            │  │
│  │  - ensono-stacks-data-processing-silver_movies      │  │
│  │  - ensono-stacks-data-processing-gold_movies        │  │
│  │  - ensono-stacks-data-ingest-azure_sql              │  │
│  │  - ensono-stacks-data-nonprod-shared_resources      │  │
│  │  ...                                                │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

---

## Naming Convention Components

### Component Breakdown

Each component in the state key serves a specific purpose:

#### 1. **Company** (`ensono`)

- **Purpose**: Organization identifier
- **Justification**:
  - Enables multi-tenant storage account usage if needed
  - Provides clear ownership in shared environments
  - Aligns with Ensono's resource naming conventions
- **Type**: Static value
- **Example**: `ensono`

#### 2. **Project** (`stacks`)

- **Purpose**: Project/product line identifier
- **Justification**:
  - Distinguishes between different Ensono products (Stacks, other frameworks)
  - Enables reuse of the same backend for multiple projects
  - Aligns with repository naming: `stacks-azure-data`
- **Type**: Static value
- **Example**: `stacks`
- **Note**: Previously incorrectly set to `data`, causing duplication

#### 3. **Domain** (`data`)

- **Purpose**: Technology domain or workload category
- **Justification**:
  - Identifies the specific Stacks offering (data platform)
  - Groups related infrastructure components together
  - Distinguishes from other potential domains (e.g., web, api, mobile)
- **Type**: Static value
- **Example**: `data`

#### 4. **Environment** (`dev`, `qa`, `uat`, `prod`)

- **Purpose**: Deployment environment identifier
- **Justification**:
  - **Critical for state isolation**: Prevents dev changes from affecting production
  - Enables parallel deployments to different environments
  - Supports environment-specific infrastructure configurations
  - Aligns with Azure DevOps environment gates and approvals
- **Type**: Dynamic value from `$(env_name)` parameter
- **Example**: `dev`, `qa`, `uat`, `prod`
- **When Used**: Infrastructure pipelines only (not data workloads)

#### 5. **Component** (varies by context)

- **Purpose**: Specific infrastructure layer or workload identifier
- **Justification**:
  - Enables independent management of different infrastructure layers
  - Supports staged deployment (network → infra → databricks)
  - Prevents circular dependencies in Terraform state
  - Allows parallel development of different components
- **Type**: Context-dependent identifier
- **Examples**:

##### Infrastructure Components:

- **`networking`**: Virtual networks, subnets, DNS zones, network security groups, private endpoints

  - Deployed first as foundation for other components
  - Referenced by infra layer for VNet integration

- **`infra`**: Core data platform resources (Data Factory, Data Lake, Key Vault, etc.)

  - Depends on networking for private endpoint configuration
  - Provides outputs consumed by databricks layer

- **`databricks`**: Databricks workspace, cluster policies, secret scopes
  - Deployed last, depends on both networking and infra
  - Requires networking for VNet injection and infra for service endpoints

##### Data Workload Components:

- **`processing-<pipeline_name>`**: Data processing workloads (silver, gold transformations)
- **`ingest-<job_name>`**: Data ingestion jobs
- **`<env>-shared_resources`**: Shared ADF resources (linked services, datasets, pipelines)

---

## Implementation Patterns

### Pattern 1: Infrastructure Pipelines

**Used by**: 9 pipeline files
**Pattern**: `$(company)-$(project)-$(domain)-$(env_name)-<component>`

#### Files Using This Pattern:

1. `build/azdo/pipeline-full-deployment.yml`
2. `build/azdo/pipeline-full-teardown.yml`
3. `build/azdo/pipeline-databricks.yml`
4. `build/azdo/pipeline-infra-private.yml`
5. `build/azdo/pipeline-networking.yml`
6. `build/azdo/stages/infra.yml`
7. `build/azdo/azure/data/pipeline.yml`
8. `build/azdo/azure/network/pipeline.yml`
9. `cicd/build/azdo/pipeline.yml`

#### Example State Keys Generated:

```yaml
# Development environment
ensono-stacks-data-dev-networking
ensono-stacks-data-dev-infra
ensono-stacks-data-dev-databricks

# Production environment
ensono-stacks-data-prod-networking
ensono-stacks-data-prod-infra
ensono-stacks-data-prod-databricks
```

#### Implementation:

```yaml
variables:
  - name: ENV_NAME
    value: ${{ parameters.env_name }}
  - name: tf_state_key
    value: $(company)-$(project)-$(domain)-$(env_name)-networking

# Template call
- template: templates/terraform-networking.yml
  parameters:
    tf_state_key: $(company)-$(project)-$(domain)-$(env_name)-networking
```

#### Why Environment is Included:

Infrastructure must be completely isolated between environments:

- **Dev** infrastructure can be torn down and recreated without affecting production
- **QA/UAT** can test infrastructure changes before prod deployment
- **Production** state remains protected and separate
- Enables blue-green deployments and disaster recovery scenarios

---

### Pattern 2: Data Engineering Shared Resources

**Used by**: 1 pipeline file
**Pattern**: `$(company)-$(project)-$(domain)-${{ stage.environment_shortname }}-$(job)`

#### Files Using This Pattern:

1. `de_workloads/shared_resources/de-shared-resources.yml`

#### Example State Keys Generated:

```yaml
ensono-stacks-data-nonprod-shared_resources
ensono-stacks-data-prod-shared_resources
```

#### Implementation:

```yaml
stages:
  - ${{ each stage in parameters.stages }}:
      - stage: ${{ stage.stage }}
        variables:
          - name: tf_state_key
            value: $(company)-$(project)-$(domain)-${{ stage.environment_shortname }}-$(job)
```

#### Why This Pattern:

- Shared resources need environment isolation (nonprod vs prod)
- Uses template parameter syntax `${{ }}` for compile-time resolution
- The `job` variable is set to `shared_resources`
- These are common ADF resources (linked services, datasets) shared by all workloads in an environment

---

### Pattern 3: Data Workload Pipelines

**Used by**: 5 pipeline files
**Pattern**: `$(company)-$(project)-$(domain)-$(workload_type)-$(pipeline_name)`
**Alternative**: `$(company)-$(project)-$(domain)-$(jobtype)-$(job)`

#### Files Using This Pattern:

1. `de_workloads/processing/silver_movies_example/de-process-ado-pipeline.yml`
2. `de_workloads/processing/gold_movies_example/de-process-ado-pipeline.yml`
3. `de_workloads/processing/silver_movies_example_with_data_quality/de-process-ado-pipeline.yml`
4. `de_workloads/ingest/ingest_azure_sql_example/de-ingest-ado-pipeline.yml`

#### Example State Keys Generated:

```yaml
# Processing workloads
ensono-stacks-data-processing-silver_movies_example
ensono-stacks-data-processing-gold_movies_example

# Ingest workloads
ensono-stacks-data-ingest-ingest_azure_sql_example
```

#### Implementation:

```yaml
variables:
  - name: workload_type
    value: processing # or 'ingest'
  - name: pipeline_name
    value: silver_movies_example
  - name: tf_state_key
    value: $(company)-$(project)-$(domain)-$(workload_type)-$(pipeline_name)
```

#### Why Environment is NOT Included:

Data workloads have different lifecycle characteristics:

- **Environment selection** happens at pipeline runtime via parameters
- **Same pipeline definition** deploys to different environments based on branch/trigger
- **State represents the workload configuration**, not environment-specific infrastructure
- **Terraform resources** are logical (ADF pipelines, datasets) not physical infrastructure
- Workloads are **promoted through environments** using the same state

#### Why Workload Type is Included:

- Distinguishes between different categories of data engineering work
- Organizes state files by functional area (ingest vs processing vs shared)
- Enables clear separation of concerns in the data platform

---

## Changes Made

### Phase 1: Variable Correction

#### Issue: Project Variable Duplication

**File**: `build/azdo/variables.yml`

**Before**:

```yaml
- name: company
  value: ensono
- name: project
  value: data # ❌ WRONG
- name: domain
  value: data
```

**After**:

```yaml
- name: company
  value: ensono
- name: project
  value: stacks # ✅ CORRECT
- name: domain
  value: data
```

**Impact**: Eliminated duplicate "data" in state keys

- Old: `ensono-data-data-networking` ❌
- New: `ensono-stacks-data-dev-networking` ✅

---

### Phase 2: Template Parameter Fixes

#### Issue: Wrong Variable Reference

Multiple pipelines used `$(environment)` instead of `$(env_name)`

**Files Changed**:

- `build/azdo/pipeline-full-deployment.yml` (3 template calls)
- `build/azdo/pipeline-full-teardown.yml` (3 template calls)
- `build/azdo/pipeline-databricks.yml` (1 template call)
- `build/azdo/pipeline-infra-private.yml` (1 template call)

**Before**:

```yaml
- template: templates/terraform-deploy.yml
  parameters:
    tf_state_key: $(company)-$(project)-$(domain)-$(environment)-infra
```

**After**:

```yaml
- template: templates/terraform-deploy.yml
  parameters:
    tf_state_key: $(company)-$(project)-$(domain)-$(env_name)-infra
```

**Reason**:

- `$(environment)` contains `nonprod` or `prod` (environment group)
- `$(env_name)` contains `dev`, `qa`, `uat`, or `prod` (specific environment)
- State keys need specific environment for proper isolation

---

### Phase 3: Variable Declaration Updates

#### Issue: Missing Environment in State Key Variables

Variable declarations at stage level didn't include environment

**Files Changed**:

- `build/azdo/pipeline-full-deployment.yml` (3 stages)
- `build/azdo/pipeline-full-teardown.yml` (3 stages)
- `build/azdo/pipeline-databricks.yml` (1 stage)
- `build/azdo/pipeline-infra-private.yml` (1 stage)
- `build/azdo/pipeline-networking.yml` (1 stage)
- `build/azdo/stages/infra.yml` (1 stage)
- `build/azdo/azure/data/pipeline.yml` (root level)
- `build/azdo/azure/network/pipeline.yml` (root level)
- `cicd/build/azdo/pipeline.yml` (root level)

**Before**:

```yaml
variables:
  - name: tf_state_key
    value: $(company)-$(project)-$(domain)-networking
```

**After**:

```yaml
variables:
  - name: tf_state_key
    value: $(company)-$(project)-$(domain)-$(env_name)-networking
```

**Impact**: Consistent environment-specific state keys across all infrastructure

---

### Phase 4: Component Name Corrections

#### Issue: Inconsistent or Wrong Component Names

**Changes Made**:

1. **azure/network/pipeline.yml**

   - Before: `$(company)-$(project)-$(domain)-network` (missing 'ing')
   - After: `$(company)-$(project)-$(domain)-$(env_name)-networking`

2. **azure/data/pipeline.yml**

   - Before: `$(company)-$(project)-$(domain)-data` (ambiguous name)
   - After: `$(company)-$(project)-$(domain)-$(env_name)-infra`
   - Reason: This pipeline deploys infrastructure resources, not just "data"

3. **cicd/build/azdo/pipeline.yml**
   - Before: `$(company)-$(project)-$(domain)-azdo` (unclear abbreviation)
   - After: `$(company)-$(project)-$(domain)-$(env_name)-infra`
   - Reason: Deploys infrastructure resources via Azure DevOps

**Impact**: Clear, consistent component naming across all pipelines

---

### Phase 5: Template Updates

#### Issue: Templates Not Accepting State Key Parameter

**File**: `build/azdo/templates/terraform-networking.yml`

**Changes**:

1. Added `tf_state_key` parameter definition
2. Changed reference from `$(tf_state_key)` to `${{ parameters.tf_state_key }}`

**Before**:

```yaml
parameters:
  - name: destroy
    type: boolean
  - name: deploy
    type: boolean

steps:
  # ...
  env:
    TF_BACKEND_INIT: "key=$(tf_state_key),storage_account_name=..."
```

**After**:

```yaml
parameters:
  - name: tf_state_key
    type: string
  - name: destroy
    type: boolean
  - name: deploy
    type: boolean

steps:
  # ...
  env:
    TF_BACKEND_INIT: "key=${{ parameters.tf_state_key }},storage_account_name=..."
```

**Impact**: Enables explicit state key passing to templates, improving clarity and testability

---

### Phase 6: Shared Resources Special Case

#### Issue: Root-Level Variable in Multi-Stage Pipeline

**File**: `de_workloads/shared_resources/de-shared-resources.yml`

**Change**: Moved `tf_state_key` from root to stage level

**Before**:

```yaml
variables:
  - name: tf_state_key
    value: $(company)-$(project)-$(domain)-$(job)

stages:
  - ${{ each stage in parameters.stages }}:
      - stage: ${{ stage.stage }}
        # Uses root-level variable
```

**After**:

```yaml
# Removed from root level

stages:
  - ${{ each stage in parameters.stages }}:
      - stage: ${{ stage.stage }}
        variables:
          - name: tf_state_key
            value: $(company)-$(project)-$(domain)-${{ stage.environment_shortname }}-$(job)
```

**Reason**:

- Each stage targets different environment (nonprod/prod)
- State key must be resolved per-stage for proper environment isolation
- Uses template parameter syntax for compile-time resolution

---

## Validation and Testing

### Pre-Deployment Validation

All changes were validated through:

1. **YAML Syntax Validation**

   - Azure DevOps pipeline YAML validation
   - Template parameter type checking
   - Variable reference resolution

2. **Pattern Consistency Check**

   - Verified all infrastructure pipelines use `$(env_name)`
   - Confirmed no remaining `$(environment)` references in state keys
   - Validated template parameter passing

3. **State Key Uniqueness**
   - Ensured no duplicate state keys across environments
   - Confirmed proper isolation between dev/qa/uat/prod
   - Validated workload-specific keys don't conflict

### Testing Matrix

| Pipeline Type       | Environment | Expected State Key                                    | Status |
| ------------------- | ----------- | ----------------------------------------------------- | ------ |
| Networking          | dev         | `ensono-stacks-data-dev-networking`                   | ✅     |
| Networking          | qa          | `ensono-stacks-data-qa-networking`                    | ✅     |
| Infrastructure      | dev         | `ensono-stacks-data-dev-infra`                        | ✅     |
| Infrastructure      | prod        | `ensono-stacks-data-prod-infra`                       | ✅     |
| Databricks          | dev         | `ensono-stacks-data-dev-databricks`                   | ✅     |
| Databricks          | prod        | `ensono-stacks-data-prod-databricks`                  | ✅     |
| Shared Resources    | nonprod     | `ensono-stacks-data-nonprod-shared_resources`         | ✅     |
| Shared Resources    | prod        | `ensono-stacks-data-prod-shared_resources`            | ✅     |
| Processing Workload | N/A         | `ensono-stacks-data-processing-silver_movies_example` | ✅     |
| Ingest Workload     | N/A         | `ensono-stacks-data-ingest-ingest_azure_sql_example`  | ✅     |

---

## Migration Guide

### For Existing Deployments

If you have existing infrastructure deployed with old state key patterns, follow this migration process:

#### Step 1: Identify Current State Files

```bash
# List all state files in storage account
az storage blob list \
  --account-name stacksstatehjfis \
  --container-name tfstate \
  --query "[].name" \
  --output table
```

#### Step 2: State File Mapping

Create a mapping of old to new state keys:

| Old State Key                   | New State Key                       | Action Required   |
| ------------------------------- | ----------------------------------- | ----------------- |
| `ensono-data-data-networking`   | `ensono-stacks-data-dev-networking` | Rename or migrate |
| `ensono-stacks-data-networking` | `ensono-stacks-data-dev-networking` | Add environment   |
| `ensono-stacks-data-infra`      | `ensono-stacks-data-dev-infra`      | Add environment   |
| `ensono-stacks-data-databricks` | `ensono-stacks-data-dev-databricks` | Add environment   |

#### Step 3: Migration Options

**Option A: State File Rename (Recommended for Dev/Test)**

```bash
# Copy old state to new key
az storage blob copy start \
  --account-name stacksstatehjfis \
  --destination-container tfstate \
  --destination-blob ensono-stacks-data-dev-networking \
  --source-container tfstate \
  --source-blob ensono-stacks-data-networking

# Verify copy completed
az storage blob show \
  --account-name stacksstatehjfis \
  --container-name tfstate \
  --name ensono-stacks-data-dev-networking

# Delete old state (after verification)
az storage blob delete \
  --account-name stacksstatehjfis \
  --container-name tfstate \
  --name ensono-stacks-data-networking
```

**Option B: Terraform State Migration (Production)**

```bash
# Pull existing state
terraform state pull > old-state.json

# Update backend configuration to new key
# Edit backend config in Terraform files

# Initialize with new backend
terraform init -migrate-state

# Verify state
terraform state list
```

**Option C: Fresh Deployment (New Environments)**

For new environments or when starting fresh:

1. Deploy with new pipeline configuration
2. New state keys will be created automatically
3. No migration needed

#### Step 4: Post-Migration Verification

```bash
# Verify infrastructure matches state
terraform plan

# Should show: No changes. Your infrastructure matches the configuration.
```

### Important Migration Notes

⚠️ **CRITICAL WARNINGS**:

1. **Always backup state files before migration**

   ```bash
   az storage blob download \
     --account-name stacksstatehjfis \
     --container-name tfstate \
     --name <old-state-key> \
     --file backup-$(date +%Y%m%d).tfstate
   ```

2. **Test in non-production first**

   - Migrate dev/qa environments before production
   - Validate deployments work with new state keys

3. **Coordinate with team**

   - Ensure no concurrent deployments during migration
   - Lock state files if possible
   - Communicate migration window to team

4. **Document environment mapping**
   - Track which old state maps to which new environment
   - Keep migration log for audit purposes

---

## Benefits Achieved

### 1. Clear Environment Isolation

✅ Each environment (dev, qa, uat, prod) has completely separate state files
✅ No risk of dev changes affecting production infrastructure
✅ Supports parallel development and testing

### 2. Consistent Naming

✅ All infrastructure pipelines follow identical pattern
✅ Predictable state key structure across the platform
✅ Easier troubleshooting and state management

### 3. Proper Component Organization

✅ Clear separation between networking, infra, and databricks layers
✅ Enables staged deployment workflows
✅ Supports independent component lifecycle management

### 4. Scalability

✅ Pattern supports adding new environments (staging, dr, etc.)
✅ Can add new infrastructure components without conflicts
✅ Workload pattern scales to hundreds of data pipelines

### 5. Operational Excellence

✅ Reduced risk of state corruption from key conflicts
✅ Simplified disaster recovery and backup strategies
✅ Better audit trail through clear state key naming
✅ Aligns with Terraform and Azure best practices

---

## Best Practices Going Forward

### 1. Never Modify State Keys Manually

State keys are generated from variables. Always update variables, not hardcoded values.

### 2. Always Include Environment for Infrastructure

New infrastructure components must include `$(env_name)` in state keys.

### 3. Document New Workload Patterns

If creating new workload types, document the state key pattern in this document.

### 4. Test State Keys in Non-Prod First

Validate state key changes work in dev before applying to production.

### 5. Maintain State Key Consistency Across Repos

If creating related repositories, use the same state key patterns.

### 6. Regular State Key Audits

Periodically review state files in storage account to ensure compliance with patterns.

---

## Reference Materials

### Variable Definitions

**Location**: `build/azdo/variables.yml`

```yaml
variables:
  - name: company
    value: ensono
  - name: project
    value: stacks
  - name: domain
    value: data
```

### Template Parameter Patterns

**Compile-time parameters** (resolved during pipeline compilation):

```yaml
${{ parameters.env_name }}
${{ stage.environment_shortname }}
```

**Runtime variables** (resolved during pipeline execution):

```yaml
$(env_name)
$(company)
$(project)
$(domain)
```

### State Backend Configuration

**Location**: Set via `TF_BACKEND_INIT` environment variable in pipelines

```bash
TF_BACKEND_INIT: "key=$(tf_state_key),storage_account_name=$(tf_state_storage),resource_group_name=$(tf_state_rg),container_name=$(tf_state_container)"
```

**Terraform Backend Block**:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "stacks-terraform-state"
    storage_account_name = "stacksstatehjfis"
    container_name       = "tfstate"
    key                  = "ensono-stacks-data-dev-networking"  # Example
  }
}
```

---

## Appendix A: Complete State Key Inventory

### Infrastructure Pipeline State Keys

| Pipeline       | Dev                                 | QA                                 | UAT                                 | Prod                                 |
| -------------- | ----------------------------------- | ---------------------------------- | ----------------------------------- | ------------------------------------ |
| Networking     | `ensono-stacks-data-dev-networking` | `ensono-stacks-data-qa-networking` | `ensono-stacks-data-uat-networking` | `ensono-stacks-data-prod-networking` |
| Infrastructure | `ensono-stacks-data-dev-infra`      | `ensono-stacks-data-qa-infra`      | `ensono-stacks-data-uat-infra`      | `ensono-stacks-data-prod-infra`      |
| Databricks     | `ensono-stacks-data-dev-databricks` | `ensono-stacks-data-qa-databricks` | `ensono-stacks-data-uat-databricks` | `ensono-stacks-data-prod-databricks` |

### Data Workload State Keys

| Workload Type              | Example State Key                                     |
| -------------------------- | ----------------------------------------------------- |
| Shared Resources (NonProd) | `ensono-stacks-data-nonprod-shared_resources`         |
| Shared Resources (Prod)    | `ensono-stacks-data-prod-shared_resources`            |
| Processing Pipeline        | `ensono-stacks-data-processing-silver_movies_example` |
| Processing Pipeline        | `ensono-stacks-data-processing-gold_movies_example`   |
| Ingest Job                 | `ensono-stacks-data-ingest-ingest_azure_sql_example`  |

---

## Appendix B: Files Modified

### Configuration Files

- `build/azdo/variables.yml` - Fixed project variable

### Infrastructure Pipelines

- `build/azdo/pipeline-full-deployment.yml` - Updated 3 state key declarations + 3 template calls
- `build/azdo/pipeline-full-teardown.yml` - Updated 3 state key declarations + 3 template calls
- `build/azdo/pipeline-databricks.yml` - Updated 1 state key declaration + 1 template call
- `build/azdo/pipeline-infra-private.yml` - Updated 1 state key declaration + 1 template call
- `build/azdo/pipeline-networking.yml` - Updated 1 state key declaration
- `build/azdo/stages/infra.yml` - Updated 1 state key declaration
- `build/azdo/azure/data/pipeline.yml` - Updated 1 state key declaration (renamed component)
- `build/azdo/azure/network/pipeline.yml` - Updated 1 state key declaration (fixed component name)
- `cicd/build/azdo/pipeline.yml` - Updated 1 state key declaration (renamed component)

### Templates

- `build/azdo/templates/terraform-networking.yml` - Added tf_state_key parameter
- `build/azdo/templates/terraform-deploy.yml` - Already had tf_state_key parameter (no change)

### Data Engineering Workloads

- `de_workloads/shared_resources/de-shared-resources.yml` - Moved tf_state_key to stage level

### Data Workload Pipelines

- No changes needed (already using correct pattern for their context)

**Total Files Modified**: 13
**Total State Key Declarations Updated**: 15

---

## Conclusion

The Terraform state key standardization effort successfully established consistent, scalable naming conventions across the entire Ensono Stacks Azure Data Platform. The new patterns provide:

- **Clear environment isolation** preventing cross-environment conflicts
- **Logical component organization** supporting staged deployments
- **Predictable naming** improving operational efficiency
- **Scalable architecture** ready for future growth

All infrastructure pipelines now follow the standard pattern `$(company)-$(project)-$(domain)-$(env_name)-<component>`, while data workloads use appropriate workload-specific patterns. This foundation ensures reliable, maintainable infrastructure management as the platform scales.

---

**Document Maintenance**:

- Update this document when adding new infrastructure components
- Document new state key patterns if workload types are added
- Keep the file inventory current as pipelines evolve
- Review annually for continued accuracy and relevance
