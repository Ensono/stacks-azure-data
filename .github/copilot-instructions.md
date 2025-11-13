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

### 4. Configuration Patterns

- **Data Sources**: Use `de_workloads/generate_examples/test_config_*.yaml` as templates
- **Pipeline Variables**: Environment-specific in Azure DevOps variable groups
- **Secrets**: Always via Azure Key Vault with `data_source_password_key_vault_secret_name`

## Integration Points

### Azure DevOps Integration

- **Variable Groups**: Follow naming `{company}-{project}-{component}-{env}-{stage}` pattern
- **Pipeline Triggers**: Path-based triggers for workload isolation
- **Deployment Gates**: NonProd → Prod promotion based on branch (`main` = prod)

### Databricks Integration

- Spark jobs use `stacks.data` imports for standardized logging, data quality, and ADF parameter handling
- Jobs always include `setup_logger(name="stacks.data", log_level=logging.INFO)`
- ADF parameters retrieved via `get_data_factory_param(index, default_value)`

### Testing Strategy

- **Unit Tests**: Mock-based testing of data transformations
- **End-to-End Tests**: Full pipeline validation with test data
- **Data Quality**: Embedded DQ checks in every pipeline using `data_quality_main()`

## Critical Developer Workflows

### Adding New Data Engineering Workload

1. Use Datastacks CLI to generate from templates in `de_workloads/generate_examples/`
2. Configure data source in `config/` YAML files
3. Implement Spark jobs in `spark_jobs/` using `stacks.data` patterns
4. Add Terraform resources in `data_factory/`
5. Configure ADO pipeline with proper variable groups

### Infrastructure Changes

1. Modify Terraform in `deploy/terraform/{infra|networking|databricks}/`
2. Update `locals.tf` for complex configurations (cannot use variables!)
3. Test with `eirctl run infrastructure_plan` before applying
4. Private networking changes require `enable_private_networks` variable

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
- **Pre-commit**: Mandatory for all commits, configured in `.pre-commit-config.yaml` ensure that this is enabled before committing

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
