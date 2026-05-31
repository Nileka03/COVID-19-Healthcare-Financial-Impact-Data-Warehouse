# Healthcare Data Warehouse & Business Intelligence
### Data Warehousing and Business Intelligence 

Year 3 · Semester 2 · 2025

---

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Architecture](#architecture)
- [Data Warehouse Design](#data-warehouse-design)
- [ETL Pipeline](#etl-pipeline)
- [SSAS Cube](#ssas-cube)
- [OLAP Operations](#olap-operations)
- [Power BI Reports](#power-bi-reports)
- [Technologies Used](#technologies-used)

---

## Project Overview

This project implements an end-to-end Data Warehousing and Business Intelligence solution for **Health Group**, a fictional hospital network. The system is designed to analyse the financial impact of the COVID-19 pandemic across the hospital network by answering key business questions:

- Which encounter types (Inpatient vs. Emergency) incurred the highest costs during the pandemic?
- Which insurance payers covered the most costs, and which left patients with significant uncovered debt?
- Which organizations and providers handled the highest patient volumes?

---

## Dataset

**Source:** [Synthea™ Synthetic Healthcare Records — COVID-19 Model](https://synthea.mitre.org/)
**Period Covered:** 2019–2020
**Total Encounters:** 321,528 transaction records

### Source Files

| File | Format | Description |
|---|---|---|
| `Encounters.csv` | SQL Server DB | Central transactional file — hospital visits, costs, payer coverage |
| `Patients.csv` | SQL Server DB | Patient demographics and geographical data |
| `Organizations.csv` | SQL Server DB | Hospital branch metadata, revenue, utilization |
| `Providers.csv` | SQL Server DB | Healthcare professional details and specialties |
| `Payers.csv` | `.csv` | Insurance company performance — covered vs. uncovered amounts |
| `Medications.csv` | `.csv` | Prescription details, base cost, total cost |
| `Procedures.csv` | `.csv` | Medical procedures performed per encounter |
| `Conditions.txt` | `.txt` | Clinical diagnosis records (including COVID-19 flags) |

---

## Architecture

```
┌──────────────────┐        ┌─────────────────────┐        ┌──────────────┐        ┌────────────┐
│   Data Sources   │        │   Staging Area       │        │ Data         │        │ BI Layer   │
│                  │        │                      │        │ Warehouse    │        │            │
│  Healthcare_     │  ETL   │  Healthcare_         │  ETL   │ Healthcare_  │ ──────▶│  Power BI  │
│  Source_DB       │───────▶│  Staging             │───────▶│ DW           │        │  SSAS      │
│  .csv files      │        │                      │        │              │        │            │
│  .txt files      │        │                      │        │              │        │            │
└──────────────────┘        └─────────────────────┘        └──────────────┘        └────────────┘
```

**ETL Tool:** SQL Server Integration Services (SSIS)
**Staging DB:** `Healthcare_Staging`
**Data Warehouse:** `Healthcare_DW`
**OLAP Layer:** SQL Server Analysis Services (SSAS)
**Reporting:** Microsoft Power BI

---

## Data Warehouse Design

### Schema — Snowflake Schema

The warehouse uses a **Snowflake Schema** to reduce redundancy through normalization. The `DimProvider` dimension is normalized through `DimOrganization` via `OrgKey`, creating the snowflake effect.

### Fact Table

**`FactEncounter`** — 321,528 rows

| Measure | Description |
|---|---|
| `BaseEncounterCost` | Base cost of each hospital visit |
| `TotalClaimCost` | Total insurance claim amount |
| `PayerCoverage` | Amount covered by the payer |
| `PatientResponsibility` | Uncovered cost borne by the patient (computed) |
| `accm_txn_create_time` | Timestamp when record was first loaded |
| `accm_txn_complete_time` | Timestamp when transaction was completed |
| `txn_process_time_hours` | Hours between creation and completion |

### Dimension Tables

| Dimension | Surrogate Key | Key Attributes | SCD Type |
|---|---|---|---|
| `DimDate` | `DateKey` | Year, Quarter, Month, Day, DayName, IsWeekend | Static |
| `DimPatient` | `PatientSK` | FirstName, LastName, Gender, Race, Address, City, State | **Type 2** |
| `DimPayer` | `PayerSK` | PayerName, Address, City, State, Phone | Type 1 |
| `DimProvider` | `ProviderSK` | ProviderName, Gender, Speciality, OrgKey | Type 1 |
| `DimOrganization` | `OrgSK` | OrgName, Address, City, State, Phone | Type 1 |
| `DimCondition` | `ConditionSK` | ConditionCode, Description, IsCovidFlag | Type 1 |
| `DimMedication` | `MedicationSK` | MedicationID, Description, BaseCost | Type 1 |
| `DimProcedures` | `ProcedureSK` | ProcedureCode, Description, BaseCost | Type 1 |

### Slowly Changing Dimensions (SCD)

- **`DimPatient` — SCD Type 2:** Changes to a patient's `Address` trigger a new record with `StartDate`, `EndDate`, and `IsCurrent` flag to preserve full history.
- **`DimPatient.LastName` — SCD Type 1:** Overwrites the current value without tracking history.

---

## ETL Pipeline

### Stage 1 — Extract to Staging

Data is extracted from all three source types and loaded into `Healthcare_Staging`. Each staging table uses an **`OnPreExecute` event handler** with a `TRUNCATE` SQL task to prevent duplicate data on re-runs.

| Source Table | Rows Loaded |
|---|---|
| Organizations | 5,499 |
| Providers | 31,764 |
| Patients | 12,352 |
| Payers | 10 |
| Conditions | 114,544 |
| Encounters | 321,528 |
| Medications | 431,262 |
| Procedures | 100,427 |

### Stage 2 — Transform & Load to Data Warehouse

Transformations are executed in dependency order (dimensions before facts, referenced dimensions before referencing ones).

**Order of execution:**
`DimConditions` → `DimMedications` → `DimProcedures` → `DimPayer` → `DimOrganization` → `DimProvider` → `DimPatient` → `FactEncounter`

Key transformations applied:

- **Data Conversion** — Financial columns cast to `NUMERIC(18,2)`; address fields converted to `DT_WSTR(50)`
- **Derived Columns** — `TRIM()` applied to all business key fields; `PatientResponsibility` calculated as `TotalClaimCost - PayerCoverage`; `Enc_Duration_Hours` derived using `DATEDIFF`
- **Lookup Transformations** — Business keys resolved to surrogate keys for all dimensions
- **SCD Wizard** — Applied to `DimPatient` to handle Type 1 and Type 2 changes
- **Stored Procedures** — Used on static dimensions to `INSERT` new records and `UPDATE` changed ones idempotently

### Stage 3 — Accumulating Fact Table

The `FactEncounter` table functions as an **Accumulating Snapshot** to track encounter lifecycle:

1. **Initial Load** — `accm_txn_create_time` populated via `GETDATE()` Derived Column
2. **Completion Update** — A separate SSIS package reads a CSV of completed encounters and uses an `OLE DB Command` UPDATE to populate `accm_txn_complete_time` and calculate `txn_process_time_hours`

---

## SSAS Cube

**Project Name:** `Healthcare_SSAS_IT23147478`
**Server:** `PC-U510KF5\SSAS`

### Configuration

- **Data Source:** `Healthcare_DW` via Microsoft OLE DB Provider for SQL Server
- **Data Source View:** `Healthcare_DSV` — all 9 tables with auto-detected relationships
- **Cube:** `Healthcare_Cube`
- **Measures:** Base Encounter Cost, Total Claim Cost, Payer Coverage, Patient Responsibility

### Hierarchies

| Hierarchy | Dimension | Levels |
|---|---|---|
| Calendar Hierarchy | `DimDate` | Year → Quarter → Month → Day |
| Location Hierarchy | `DimOrganization` | State → City → Org Name |

---

## OLAP Operations

All OLAP operations demonstrated via Excel PivotTable connected to the SSAS Cube.

| Operation | Description | Example |
|---|---|---|
| **Roll-Up** | Aggregates from lower to higher granularity | Daily costs → Monthly → Yearly → Grand Total (41,384,265.92) |
| **Drill-Down** | Navigates from summary to detail | Year 2018 → Q1 → January → Day-level costs |
| **Slice** | Filters cube on a single dimension value | Payer = Medicaid only |
| **Dice** | Filters on two or more dimensions simultaneously | Payer = Medicaid AND IsCovidFlag = Yes → Grand Total: 1,420.76 |
| **Pivot** | Swaps rows and columns for a different perspective | Payers on Rows / Years on Columns ↔ Years on Rows / Payers on Columns |

---

## Power BI Reports

**Data Source:** `Healthcare_DW` on `PC-U510KF5\SQLEXPRESS`
**Model:** Star Schema with `FactEncounter` at centre

**DAX Measure:**
```dax
Total Cost = SUM(FactEncounter[BaseEncounterCost])
```

### Reports

| Report | Visual | Description |
|---|---|---|
| **Report 1** | Matrix | Total Cost by State/City (rows) × Year (columns) — geographic + temporal cross-tab |
| **Report 2** | Pie Chart + Cascading Slicers | Cost distribution by payer; State slicer dynamically filters City slicer |
| **Report 3** | Clustered Column Chart | Hierarchical drill-down: Year → Quarter → Month |
| **Report 4** | Detail Table + Drill-through | Patient-level detail (Name, Condition, Medication, Cost) accessible via right-click drill-through from Report 2 |

---

## Technologies Used

| Tool | Purpose |
|---|---|
| SQL Server 2019 / Express | Source DB, Staging, Data Warehouse |
| SSIS (SQL Server Integration Services) | ETL pipeline |
| SSAS (SQL Server Analysis Services) | Multidimensional OLAP cube |
| Visual Studio / SSDT | SSIS & SSAS project development |
| Microsoft Excel | OLAP operation demonstrations via PivotTable |
| Microsoft Power BI Desktop | BI dashboards and reports |
| Power BI Service | Online report publishing |
| Synthea™ | Synthetic healthcare data generation |

---

