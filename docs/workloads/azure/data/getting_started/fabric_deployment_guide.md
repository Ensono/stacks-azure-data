---
id: fabric_deployment_guide
title: Fabric Lakehouse Deployment
sidebar_label: 9. Fabric Lakehouse Deployment
hide_title: false
hide_table_of_contents: false
description: Deployment of common Azure Data Factory resources shared by data pipelines
keywords:
  - data
  - infrastructure
  - adf
  - cicd
  - fabric
---

This section provides an overview of deploying microsoft fabric through Azure portal for Ensono Stacks Data Platform.


## Step 1: Create fabric capacity resource

1. Login to azure portal, search for Fabric and select Create.

![Ensono Stacks Fabric look](../images/fabric_lookup.png)

2. Create a fabric resource.
![Ensono Stacks Fabric create](../images/fabric_create.png)
   1. Select the subscription for the new fabric capacity.
   2. Create a new resource group for this fabric capacity, or select an existing one.
   3. Enter the name used to identify this resource and is displayed in the Microsoft Fabric admin portal and Azure portal. The name must be unique in the selected location. Only lowercase letters and numbers may be used.
   4. Enter the region.
   5. Select the resource size that best meets your needs.
   6. Microsoft Fabric capacity administrator will manage the capacity. The capacity administrator must be a member user or a service principal in your AAD tenant.

## Step 2: Create a Microsoft Fabric Workspace

Workspaces are places to collaborate with colleagues to create collections of items such as lakehouses, warehouses, and reports.

1. Sign-in to your organization's PowerBI portal at https://app.powerbi.com. you would need to ask your IT admin to grant a PowerBI pro license and workspace admin rights on your account to create workspaces.

2. Select workspaces from left plane and choose new workspace from bottom.
![Ensono Stacks Fabric workspace](../images/fabric_workspaces_powerbi.png)

3. Enter the name of workspace and under advanced options choose "fabric" for license mode and scroll down for step 4.
![Ensono Stacks Fabric workspace](../images/fabric_choose_fabric.png)

4. Choose the Azure fabric capacity resource created at ## Step 1 and hit "Apply".
![Ensono Stacks Fabric capacity link](../images/fabric_capacity_link.png)

5. Select newly created workspace from left workspaces panel.
![Ensono Stacks Fabric select workspace](../images/fabric_select_workspace.png)

6. From header menu choose New and select "more options"
![Ensono Stacks Fabric options](../images/fabric_more_options.png)

7. Choose Lakehouse, and provide Name.
![Ensono Stacks Fabric new lakehouse](../images/fabric_new_lakehouse.png)

8. Right click on files option on left side plane and choose "New shortcut".
![Ensono Stacks Fabric new shortcut](../images/fabric_create_shortcut.png)

9. Under "External sources" select "Azure Data Lake Storage Gen2".
![Ensono Stacks Fabric adls shortcut](../images/fabric_dfs_shortcut.png)

10. Provide connection details for your ADLS storage account and hit "Next".
![Ensono Stacks Fabric adls connection](../images/fabric_dfs_connection.png)
  1. URL: the url for ADLS gen2 endpoint to connect.
  2. connection ( leave blank)
  3. connection name ( can be left as is)
  4. Authentication type, can very depending on organization's need, SAS token is advised.

## Step 3: TO be ADDED by DE
