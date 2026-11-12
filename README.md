# 🛒 Retail Sales Data Engineering Pipeline | Databricks

An end-to-end Retail Sales Data Engineering project built using **Databricks, PySpark, Apache Spark, Delta Lake, and Spark SQL**.

This project implements the Medallion Architecture (Bronze → Silver → Gold) to ingest raw retail sales data, perform data quality transformations, and build an analytics-ready dimensional data model.

## 🏗️ Architecture

```text
             Retail Sales CSV
                    |
                    ▼
          Databricks Auto Loader
                    |
                    ▼
             BRONZE LAYER
              Delta Table
          Raw Data Ingestion
          Schema Rescue Mode
          Checkpoint Management
                    |
                    ▼
             SILVER LAYER
              Delta Table
          Schema Enforcement
          Data Type Casting
          Missing Value Handling
          Data Reconstruction
          Duplicate Handling
          Delta MERGE
                    |
                    ▼
              GOLD LAYER
              Star Schema
                    |
          ┌─────────┴──────────┐
          │                   │
      Dimensions          Fact Table
          │                   │
          ├─ dim_product      │
          ├─ dim_customer     │
          ├─ dim_date         │
          └─ dim_channel      │
                              │
                         fact_sales
                              |
                              ▼
                    Analytics & Reporting
```

## 🚀 Project Overview

The objective is to build a structured data engineering pipeline that transforms raw retail transaction data into reliable analytical datasets.

The pipeline consists of three layers:

- **Bronze:** Raw data ingestion using Databricks Auto Loader.
- **Silver:** Data cleaning, schema enforcement, data reconstruction, and deduplication.
- **Gold:** Dimensional modeling using a Star Schema for analytical workloads.

## 🥉 Bronze Layer – Data Ingestion

The Bronze layer ingests raw CSV files using **Databricks Auto Loader**.

Key implementations:

- Incremental file ingestion using Spark Structured Streaming.
- CSV ingestion using the `cloudFiles` format.
- Schema tracking using `cloudFiles.schemaLocation`.
- Schema evolution using rescue mode.
- Checkpoint management for streaming progress.
- File-level metadata extraction using `_metadata.file_path`.
- Ingestion timestamp tracking.
- Available-now trigger for processing available files and terminating the stream.

**Storage:**

`main.bronze.sales`

## 🥈 Silver Layer – Data Cleaning & Transformation

The Silver layer applies data quality rules and transformations to the Bronze data.

Key implementations:

**1. Schema Enforcement**
- Define an explicit PySpark `StructType` schema.
- Cast columns into their expected data types.
- Standardize the structure of the dataset.

**2. Missing Value Reconstruction**
- Reconstruct missing `Price_Per_Unit` values using:

  `Price_Per_Unit = Total_Spent / Quantity`

- Apply the calculation only when the quantity is non-null and non-zero.

**3. Missing Item Reconstruction**
- Generate missing item names using observed price values.
- Create item identifiers based on a generated item number and category code.
- Map retail categories to predefined category abbreviations.

**4. Duplicate Handling**
- Remove duplicate transactions using `Transaction_ID` as the deduplication key.

**5. Delta Lake MERGE**
- Use Delta Lake `MERGE` to insert previously unseen transactions.
- Avoid inserting transaction IDs that already exist in the Silver table.

**Storage:**

`main.silver.sales`

## 🥇 Gold Layer – Dimensional Modeling

The Gold layer transforms the cleaned Silver data into a dimensional model using a **Star Schema**.

The model consists of four dimension tables and one fact table.

### Dimension Tables

| Table | Description |
|---|---|
| `dim_product` | Product and category information |
| `dim_customer` | Unique customer information |
| `dim_date` | Calendar attributes including day, month, quarter, year, and weekends |
| `dim_channel` | Location and payment method information |

### Fact Table

**`fact_sales`**

Contains transaction-level sales measures and foreign keys referencing the dimension tables.

Key columns:

- Transaction_ID
- customer_key
- product_key
- date_key
- channel_key
- Quantity
- Price_Per_Unit
- sales_amount
- Discount_Applied

The fact table joins the Silver sales data with the four dimension tables to produce an analytics-ready dataset.

**Gold Tables:**

- `main.gold.dim_product`
- `main.gold.dim_customer`
- `main.gold.dim_date`
- `main.gold.dim_channel`
- `main.gold.fact_sales`

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Databricks | Data engineering platform |
| PySpark | Distributed data processing |
| Apache Spark | Processing engine |
| Auto Loader | Incremental file ingestion |
| Delta Lake | Reliable table storage and MERGE |
| Spark Structured Streaming | Streaming ingestion |
| Spark SQL | Data transformations and dimensional modeling |
| Unity Catalog | Catalog and schema organization |
| Python | Pipeline development |

## 📂 Project Structure

```text
Retail-Sales-Pipeline/
│
├── Notebooks/
│   ├── 01_bronze_ingestion
│   ├── 02_silver_cleaning
│   └── 03_gold_transformation
│
├── README.md
└── .gitignore
```

## ⚙️ Execution Workflow

1. Upload the retail sales CSV files to the Databricks Volume.
2. Configure the Auto Loader source, schema, and checkpoint locations.
3. Execute the Bronze ingestion process.
4. Run Silver transformations and data quality operations.
5. Execute Gold dimensional transformations.
6. Query the final fact and dimension tables using Spark SQL.

## 🎯 Key Engineering Concepts Demonstrated

- Medallion Architecture implementation.
- Incremental ingestion using Auto Loader.
- Schema evolution and rescued data handling.
- Explicit schema enforcement with PySpark.
- Data quality and missing value reconstruction.
- Duplicate handling and Delta Lake MERGE.
- Star Schema and dimensional modeling.
- Surrogate key generation.
- Fact and dimension table creation.

## 👨‍💻 Author

**Nithin A R**

Aspiring Data Engineer

**Technologies:** Databricks | PySpark | Python | SQL | AWS

GitHub: [@nithinarevankar](https://github.com/nithinarevankar)

---

⭐ If you find this project useful, feel free to star the repository!