Data Source
-----------
Kaggle F1 World Championship Dataset (1950-2024)
https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020

How tables were built and data was imported
--------------------------------------------
1. Run create.sql to create all 14 tables in foreign-key-safe order.
2. Run load.sql to bulk load data from the CSV files in the "archive 2" folder using PostgreSQL's \copy command.
3. driver_standings and constructor_standings use a staging table approach to apply BCNF transformations (boolean mapping from positionText).
