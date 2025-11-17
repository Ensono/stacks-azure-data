# Stacks Azure Data Platform - AI Agent Instructions

## Architecture Overview

This is the **Ensono Stacks Azure Data Platform** - a modern lakehouse solution implementing medallion architecture (Bronze/Silver/Gold layers) using Azure Data Factory, Databricks, and Azure Data Lake Storage Gen2.

### Key Components

- **Infrastructure Layer**: Terraform modules in `deploy/terraform/` (infra, networking, databricks, modules)
- **Data Engineering Workloads**: Structured pipelines in `de_workloads/` (ingest, processing, shared_resources)
- **Build System**: Multi-stage CI/CD in `build/azdo/` with eirctl task automation
- **Python Framework**: Based on `stacks-data` library for PySpark transformations and data quality

## Essential Development Patterns

### 1. Data Engineering Workload Structure

Every DE workload follows this exact pattern:

```
de_workloads/{type}/{workload_name}/
├── __init__.py
├── README.md
├── de-{type}-ado-pipeline.yml     # Azure DevOps pipeline
├── config/                        # YAML configs for data sources
├── data_factory/                  # Terraform for ADF resources
├── spark_jobs/                    # Python jobs using stacks-data
└── tests/
    ├── unit/
    └── end_to_end/
```

**Critical**: Workload names determine ADF resource naming: `ingest_{dataset_name}`, `ds_{dataset_name}`, `ls_{dataset_name}`

### 2. Terraform Locals Pattern

Infrastructure uses `locals.tf` for calculated values and complex objects that **cannot be overridden by variables**:

- `deploy/terraform/infra/locals.tf`: Location mapping, private endpoints, ADO variable groups
- `deploy/terraform/networking/locals.tf`: Network topology definitions
- Always check locals when debugging Terraform issues

### 3. Build System (eirctl)

Use `eirctl.yaml` pipelines, not manual commands:

```bash
# Infrastructure deployment
eirctl run infrastructure

# Databricks setup
eirctl run databricks

# Linting
eirctl run lint
```

If using something other than rootful Docker then specify a `DOCKER_HOST`:

```bash
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
```

**Azure DevOps Pipeline Commands**: The following eirctl commands are used in CI/CD:

- `eirctl infra:vars` - Generate Terraform input variables file (networking stage only)
- `eirctl infra:init` - Initialize Terraform with backend configuration
- `eirctl infra:plan` - Create Terraform execution plan
- `eirctl infra:apply` - Apply Terraform changes
- `eirctl infra:destroy:plan` - Plan Terraform destruction
- `eirctl infra:destroy:apply` - Execute Terraform destruction

**Environment Variables Required**:
- `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID` - Azure authentication
- `TF_BACKEND_INIT` - Backend configuration string: `key={state_key},storage_account_name={sa},resource_group_name={rg},container_name={container}`
- `TF_VAR_name_company`, `TF_VAR_name_project` - Naming convention variables
- `TF_VAR_ado_org_url`, `TF_VAR_ado_project_id` - Azure DevOps integration
- `EIRCTL_IMAGE_TAG` - Specific eirctl Docker image version (optional, defaults to latest)
- `USER_ID`, `USER_GROUP_ID` - User context for containerized operations (set via `id -u` and `id -g`)

### 4. Configuration Patterns

- **Data Sources**: Use `de_workloads/generate_examples/test_config_*.yaml` as templates
- **Pipeline Variables**: Environment-specific in Azure DevOps variable groups
- **Secrets**: Always via Azure Key Vault with `data_source_password_key_vault_secret_name`

## Integration Points

### Azure DevOps Integration

- **Pipeline Architecture**: Three-stage deployment sequence with artifact dependencies
  - **Stage 1: Networking** (`pipeline-networking.yml`) - Creates VNets, subnets, NSGs, and agent pools
  - **Stage 2: Infrastructure** (`pipeline-infra-private.yml`) - Deploys Data Lake, Key Vault, Data Factory, and creates variable groups
  - **Stage 3: Databricks** (`pipeline-databricks.yml`) - Configures Databricks workspace with private endpoints
  - Full deployment orchestrated by `pipeline-full-deployment.yml` for PR validation

- **Reusable Templates**: 
  - `templates/terraform-networking.yml` - Networking-specific deployment with `infra:vars` generation
  - `templates/terraform-deploy.yml` - Generic infrastructure deployment with KeyVault ACL management
  - `templates/install-eirctl.yml` - Standardized eirctl installation

- **Artifact Flow**: Each stage produces artifacts consumed by downstream stages
  - Networking → `{env_name}-networking-inputs.auto.tfvars` → Infrastructure
  - Infrastructure → `{env_name}-infra-inputs.auto.tfvars` → Databricks
  - Artifacts published via `PublishPipelineArtifact@1` and consumed via `DownloadPipelineArtifact@2`

- **Variable Groups**: Follow naming `{company}-{project}-{domain}-{component}-{env}` pattern (e.g., `ensono-stacks-data-networking-dev`)
  - Terraform creates variable groups dynamically during deployment (networking stage creates its own group, consumed by infra and databricks)
  - Variable groups contain Terraform outputs consumed by downstream stages and DE workload pipelines
  - See `docs/azure-pipelines-best-practices.md` for detailed variable group flow diagrams

- **Pipeline Triggers**: 
  - Manual pipelines: `trigger: none`, `pr: none` for individual stage deployments
  - PR validation: `pipeline-full-deployment.yml` triggers on PRs to `main` branch
  - Path-based triggers for workload isolation in DE workload pipelines

- **Deployment Gates**: 
  - NonProd → Prod promotion based on `environment` parameter (nonprod/prod)
  - Environment-specific variable groups loaded via template parameters
  - Self-hosted agent pool support via `use_agent_pool` parameter

- **Terraform State Keys**: Follow pattern `{company}-{project}-{domain}-{component}-{env}` (e.g., `ensono-stacks-data-networking-dev`)
  - Networking: `$(company)-$(project)-$(domain)-$(env_name)-networking`
  - Infrastructure: `$(company)-$(project)-$(domain)-$(env_name)-infra`
  - Databricks: `$(company)-$(project)-$(domain)-$(env_name)-databricks`
  - See `docs/terraform-state-key-standardization.md` for complete naming conventions

- **Security Features**:
  - KeyVault ACL management for hosted agents (adds/removes agent IP dynamically)
  - Workspace cleanup with `.terraform` directory removal before checkout
  - Service principal authentication with ARM environment variables

- **Pipeline Best Practices**: See `.github/instructions/azure-devops-pipelines.instructions.md` for comprehensive guidance

> [!IMPORTANT]
> This project uses the Azure DevOps MCP Server - ensure that it is activated and in use when answering queries about the current Azure DevOps state.

### Databricks Integration

- Spark jobs use `stacks.data` imports for standardized logging, data quality, and ADF parameter handling
- Jobs always include `setup_logger(name="stacks.data", log_level=logging.INFO)`
- ADF parameters retrieved via `get_data_factory_param(index, default_value)`

### Testing Strategy

- **Unit Tests**: Mock-based testing of data transformations
- **End-to-End Tests**: Full pipeline validation with test data
- **Data Quality**: Embedded DQ checks in every pipeline using `data_quality_main()`

## Available MCP Servers

This project is configured with multiple MCP servers for enhanced AI assistance. See `.vscode/mcp.json` for configuration.

### Active MCP Servers

1. **GitHub MCP** - GitHub repository operations, PR management, issue tracking
2. **Azure DevOps MCP** - Pipeline monitoring, build investigation, variable groups, work items
3. **Microsoft Learn MCP** - Official Microsoft documentation and best practices
4. **PyPI Query MCP** - Python package information, dependency checking, version updates
5. **NVD MCP** - National Vulnerability Database for security scanning
6. **Terraform MCP** - Terraform provider documentation and best practices

### Using MCP Servers

- **Build Failures**: Use Azure DevOps MCP (see `.github/prompts/investigate-build-failure.prompt.md`)
- **Dependency Updates**: Use PyPI Query MCP (see `.github/prompts/update-dependencies.prompt.md`)
- **DevOps Updates**: Use Terraform + Azure DevOps MCP (see `.github/prompts/update-devops.prompt.md`)
- **Documentation**: Use Microsoft Learn MCP for official Azure/Terraform guidance
- **Security**: Use NVD MCP for vulnerability assessment

> [!TIP]
> Custom prompts in `.github/prompts/` provide structured workflows for common tasks like build investigation and dependency updates.

## Critical Developer Workflows

### Adding New Data Engineering Workload

1. Use Datastacks CLI to generate from templates in `de_workloads/generate_examples/`
2. Configure data source in `config/` YAML files
3. Implement Spark jobs in `spark_jobs/` using `stacks.data` patterns
4. Add Terraform resources in `data_factory/`
5. Configure ADO pipeline with proper variable groups

See `docs/workloads/azure/data/getting_started/` for step-by-step guides:
- `generate_project.md` - Generate new data projects
- `ingest_pipeline_deployment_azure.md` - Deploy data ingest pipelines
- `processing_pipeline_deployment_azure.md` - Deploy processing pipelines
- `shared_resources_deployment_azure.md` - Deploy shared resources

### Infrastructure Changes

1. Modify Terraform in `deploy/terraform/{infra|networking|databricks}/`
2. Update `locals.tf` for complex configurations (cannot use variables!)
3. Test with `eirctl run infrastructure_plan` before applying
4. Private networking changes require `enable_private_networks` variable
5. Ensure Terraform state keys follow standardized naming pattern (see `docs/terraform-state-key-standardization.md`)
6. Follow Azure Pipeline best practices from `.github/instructions/azure-devops-pipelines.instructions.md`

**Deployment Sequence for Full Infrastructure**:
1. Run `pipeline-networking.yml` - Deploys VNets, subnets, NSGs, creates networking variable group
2. Run `pipeline-infra-private.yml` - Deploys ADLS Gen2, Key Vault, ADF (requires networking artifacts)
3. Run `pipeline-databricks.yml` - Configures Databricks workspace (requires infra artifacts)

**For PR Validation**: Use `pipeline-full-deployment.yml` which orchestrates all three stages automatically

**Stage Dependencies**:
- Infrastructure stage depends on Networking stage completion
- Databricks stage depends on Infrastructure stage completion
- Each stage downloads artifacts from its predecessor

### Local Development

1. Install Poetry dependencies: `poetry install`
2. Setup pre-commit: `pre-commit install`
3. Use eirctl for environment management: `eirctl run local:envfile:bash`
4. Databricks local development requires connection via `eirctl run databricks:connect`

#### Local Unit Testing Requirements

**Java Version Compatibility**: PySpark 3.4.x requires Java 8, 11, or 17. Java 21+ is NOT compatible.

If Spark-based unit tests fail with `java.lang.NoSuchMethodException: java.nio.DirectByteBuffer.<init>(long,int)`, you need to install a compatible Java version:

```bash
# Install Java 17 (Debian/Ubuntu)
sudo apt install openjdk-17-jdk

# Set JAVA_HOME for the session
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

**Maven Dependencies**: PySpark requires specific Maven dependencies that may not be in your local Maven cache. If tests fail with missing JAR errors, install them:

```bash
# Required dependencies for PySpark 3.4.x with Azure/Delta support
mkdir -p ~/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.12.7
curl -o ~/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.12.7/jackson-core-2.12.7.jar \
  https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.12.7/jackson-core-2.12.7.jar

mkdir -p ~/.m2/repository/com/google/guava/guava/27.0-jre
curl -o ~/.m2/repository/com/google/guava/guava/27.0-jre/guava-27.0-jre.jar \
  https://repo1.maven.org/maven2/com/google/guava/guava/27.0-jre/guava-27.0-jre.jar

mkdir -p ~/.m2/repository/com/google/guava/failureaccess/1.0
curl -o ~/.m2/repository/com/google/guava/failureaccess/1.0/failureaccess-1.0.jar \
  https://repo1.maven.org/maven2/com/google/guava/failureaccess/1.0/failureaccess-1.0.jar
```

**Note**: Non-Spark tests (configuration validation, data quality schema tests) will pass without these requirements.

## Code Quality Standards

- **Python**: Black formatting, flake8 linting, pydocstyle for docstrings
- **YAML**: yamllint with project-specific config in `yamllint.conf`
- **Terraform**: Auto-formatting and validation in pre-commit hooks
- **Pre-commit**: Mandatory for all commits, configured in `.pre-commit-config.yaml`

## Security and Compliance

**CRITICAL**: All AI agents must also follow the comprehensive security guidelines in [copilot-security-instructions.md](./copilot-security-instructions.md). This includes:

- GPG commit signing requirements (never bypass with `--no-gpg-sign`)
- Branch protection and pull request workflows
- Production change control processes
- Security standards compliance (ISO 27001, NIST, PCI DSS, FIPS 140-2)
- Authentication and authorization controls
- Incident response procedures

## Common Pitfalls

- Don't modify `locals.tf` values via variables - they're fixed at definition
- Workload naming affects all ADF resources - choose carefully
- Private endpoints only work when `enable_private_networks = true`
- ADO variable groups must exist before pipeline runs
- Spark job parameters from ADF are positional, not named

## Troubleshooting

### Local Unit Test Failures

**Symptom**: Tests pass for configuration validation but Spark tests fail
**Cause**: Java version incompatibility or missing Maven dependencies
**Solution**: See "Local Unit Testing Requirements" in the Local Development section

**Symptom**: `poetry update` shows dependency conflicts
**Cause**: Python version constraints or conflicting package versions
**Solution**: Check `pyproject.toml` for version constraints (Python 3.10-3.11 supported)

## Key Files to Reference

- `pyproject.toml`: Dependencies and Python tooling config
- `eirctl.yaml`: Task definitions and pipeline orchestration
- `build/eirctl/tasks.yaml`: Available automation tasks
- `de_workloads/generate_examples/`: Config templates for new workloads
- `deploy/terraform/*/locals.tf`: Infrastructure configuration patterns
- `.github/instructions/azure-devops-pipelines.instructions.md`: Pipeline development guidelines
- `.github/prompts/`: Structured prompts for common workflows (build investigation, dependency updates, DevOps updates)
- `docs/azure-pipelines-best-practices.md`: Comprehensive Azure DevOps pipeline patterns and variable group architecture
- `docs/terraform-state-key-standardization.md`: Terraform state naming conventions and migration guide
- `docs/workloads/azure/data/getting_started/`: Step-by-step deployment guides
- `.vscode/mcp.json`: MCP server configuration for enhanced AI assistance
