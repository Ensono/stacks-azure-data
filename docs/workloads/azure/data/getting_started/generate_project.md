---
id: generate_project
title: Generate a data project
sidebar_label: 1. Generate a data project
hide_title: false
hide_table_of_contents: false
description: Generate a new data project using Stacks
keywords:
  - stacks cli
  - data
  - azure
  - template
---

This section provides an overview of generating a new Data Platform project using Stacks.

It assumes the following [requirements](../requirements_data_azure.md) are in place:

* A [remote git repository](../requirements_data_azure.md#git-repository) for hosting the generated project
* [Terraform state storage](../requirements_data_azure.md#terraform-state-storage)

## Step 1: Create/Generate Data Platform project using Stacks CLI

The [Stacks CLI](https://stacks.amido.com/docs/stackscli/about) will help you get started with scaffolding your applications and workspaces using Stacks. Through a series of questions the CLI will determine how and what to build for your workspace, helping to accelerate your development process.

Download and install the `stacks-cli` using [Stacks CLI](https://stacks.amido.com/docs/stackscli/about) page. Please refer to the **Stacks.CLI.Manual** in the latest `stacks-cli` release for detailed instruction.

To construct a Data Platform project, two primary cli commands are required: `stacks-cli interactive` and `stacks-cli scaffold`.

The interactive command is designed to ask questions on the command line about the configuration
required for setting up Ensono Digital Stacks. It will then save this configuration out to a file that can be
read in using the scaffold command.

```cmd
stacks-cli interactive
```

The majority of the questions are self-explanatory; please refer to the **Stacks.CLI.Manual** for further detail, however the following two will define the type of the target project.

| Question                                      | Required value for data project |
|-----------------------------------------------|---------------------------------|
| What framework should be used for the project?| infra                           |
| Which type of infrastructure is required?     | data                            |

The resulting configuration file named `stacks.yml` contains all of the configuration that was used to generate the project,
which means it can be used to produce the same project stack again.

The CLI can be used with a configuration file to generate the Ensono Digital Stacks based projects using `stacks-cli scaffold`.

```cmd
stacks-cli scaffold -c ./stacks.yml
```

Open the project locally and push the generated project to the target remote repository's `main` branch.

## Next steps

Now you have generated a new data project, [deploy the core infrastructure](core_data_platform_deployment_azure.md).
