
# 🏎️ Formula 1 Race Analytics

### PostgreSQL | Relational Database Design | SQL | Data Analytics

An end-to-end data engineering and analytics project built around historical **Formula 1 World Championship data (1950–2024)**. Designed a structured **PostgreSQL database with 14 relational tables**, implemented CSV data ingestion, and organized racing data for analytical exploration.

## 📌 Project Overview

Formula 1 generates large amounts of interconnected data involving drivers, constructors, circuits, races, results, and championship standings.

This project focuses on transforming historical racing datasets into a structured relational database to enable efficient data management, querying, and analysis.

The implementation is organized into two phases covering database design, data ingestion, normalization, and analytics.

## 🛠️ Technology Stack

| Category | Technologies |
|----------|-------------|
| Database | PostgreSQL |
| Programming & Queries | SQL |
| Data Engineering | CSV Ingestion, ETL, Data Transformation |
| Database Concepts | Relational Modeling, Foreign Keys, BCNF Normalization |
| Tools | PostgreSQL, psql |

## 📊 Project Highlights

- **14 relational tables** designed to organize interconnected Formula 1 datasets.
- **1950–2024 historical data** covering decades of Formula 1 racing.
- **Foreign key relationships** to maintain referential integrity.
- **Automated CSV ingestion** using PostgreSQL `\copy`.
- **Staging tables and transformations** for driver and constructor standings.
- **SQL-based analytics** supported by normalized relational data.

## 🏗️ System Architecture

```text
       Formula 1 Historical Dataset
                  |
                  v
           Raw CSV Files
                  |
                  v
        PostgreSQL Ingestion
              (load.sql)
                  |
                  v
       Data Cleaning & Staging
                  |
                  v
       Relational Data Modeling
             (14 Tables)
                  |
                  v
         PostgreSQL Database
                  |
                  v
          SQL Data Analysis
                  |
                  v
          Analytical Insights
```

## 🗄️ Database Design

Designed a relational database to represent key Formula 1 entities and their relationships.

The data model includes information about:

- Drivers and constructors
- Races and circuits
- Race results
- Championship standings
- Other racing statistics and reference data

### Schema Implementation

The `create.sql` script creates the database tables in an order that respects foreign key dependencies.

### Database Normalization

Applied staging-table transformations to driver and constructor standings data, including work related to BCNF normalization.

These transformations support more structured storage and consistent relational querying.

## ⚙️ Data Ingestion Pipeline

Implemented a PostgreSQL data ingestion workflow to load historical Formula 1 data into relational tables.

**Pipeline:**

1. Extract historical racing records from CSV datasets.
2. Create the required PostgreSQL tables.
3. Load datasets using the `\copy` command.
4. Transform standings data through staging tables.
5. Prepare structured data for SQL queries and analysis.

The workflow uses `create.sql` for schema creation and `load.sql` for data ingestion.

## 📁 Repository Structure

```text
F1-Race-Analytics/
│
├── Phase-2/           # Phase 2 project artifacts
├── Phase_1.pdf        # Phase 1 documentation
├── Phase_2.pdf        # Phase 2 documentation
├── Demo.mp4           # Recorded project demonstration
├── Phase-2.zip        # Archived Phase 2 files
├── f1_final           # Additional project artifact
└── readme.txt         # Original setup and dataset notes
```

## 🚀 Getting Started

### Prerequisites

- PostgreSQL
- psql command-line client
- Formula 1 historical CSV dataset

### 1. Clone the Repository

```bash
git clone https://github.com/3129sindhu/F1-Race-Analytics.git
cd F1-Race-Analytics
```

### 2. Locate the SQL Scripts

Find `create.sql` and `load.sql` within the project artifacts.

Update any local CSV paths in `load.sql` to match your machine.

### 3. Create the Database

```bash
createdb f1_analytics
```

### 4. Create the Tables

From the directory containing the SQL scripts:

```bash
psql -d f1_analytics -f create.sql
```

### 5. Load the Dataset

```bash
psql -d f1_analytics -f load.sql
```

Ensure the CSV files are available at the paths referenced by the loading script.

## 📄 Project Documentation

The project includes detailed reports describing the database implementation and analytical work.

- 📘 [Phase 1 Report](Phase_1.pdf)
- 📗 [Phase 2 Report](Phase_2.pdf)
- 🎥 [Watch Project Demo](Demo.mp4)

## 📈 Key Engineering Concepts

**Relational Database Design**

Modeled Formula 1 entities using interconnected relational tables and foreign keys.

**Data Engineering**

Built a structured CSV ingestion and transformation workflow using PostgreSQL.

**Database Normalization**

Explored BCNF-related transformations to organize racing standings data.

**SQL Analytics**

Prepared structured datasets to support analytical queries over historical racing data.

## 📚 Dataset

**Formula 1 World Championship Dataset (1950–2024)**

Source: [Kaggle Formula 1 Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

Dataset credit belongs to the original creator and underlying data sources.

---

### Project Focus

**Database Engineering • Relational Data Modeling • SQL • Data Engineering • Formula 1 Analytics**
