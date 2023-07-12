Feature:Data Factory Generate Ingest Query
  I want to generate the ingest query
  so that I can ingest data

  Scenario Outline: Generate Data Factory Ingest query
    Given the ADF pipeline Generate_Ingest_Query has been triggered with <parameters>
    And I poll the pipeline every 10 seconds until it has completed
    And the ADF pipeline Generate_Ingest_Query has finished with state Succeeded
    And the ADF pipeline completed in less than 120 seconds

    Examples: Generate query
    |parameters|
    |{"window_start" : "2020-01-01", "window_end": "2020-01-31", "ingest_entity_config":{"version": 1, "display_name": "SalesLT.SalesOrderHeader", "enabled": true, "schema": "SalesLT", "table": "SalesOrderHeader", "columns": "SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, ShipToAddressID, BillToAddressID, ShipMethod, CreditCardApprovalCode, SubTotal, TaxAmt, Freight, TotalDue, Comment, rowguid, ModifiedDate", "load_type": "delta", "delta_date_column": "ModifiedDate", "delta_upsert_key": "SalesOrderID"}}|
