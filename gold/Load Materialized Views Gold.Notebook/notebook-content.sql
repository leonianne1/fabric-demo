-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "synapse_pyspark"
-- META   },
-- META   "dependencies": {
-- META     "lakehouse": {
-- META       "default_lakehouse": "4e7741a9-f2d7-4abe-a1bc-f1e91f4893a0",
-- META       "default_lakehouse_name": "Gold_Lakehouse",
-- META       "default_lakehouse_workspace_id": "c7d9ff6f-a7ed-4ef6-9da6-0bc9c6227df8",
-- META       "known_lakehouses": [
-- META         {
-- META           "id": "4e7741a9-f2d7-4abe-a1bc-f1e91f4893a0"
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- CELL ********************

CREATE SCHEMA IF NOT EXISTS gold

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.OrderPriority
AS SELECT
   distinct(Order_Priority) AS Order_Priority,
   Order_ID
FROM silver.sales_data_cleaned
GROUP BY Order_Priority, Order_ID;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.sales_shipmode
AS SELECT
  Ship_Mode
FROM silver.sales_data_cleaned
GROUP BY Ship_Mode;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.sales_products
AS SELECT
    Product_Category,
    Product
FROM silver.sales_data_cleaned
GROUP BY Product_Category, Product;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.customer_data
AS SELECT
    Customer_ID,
    Order_ID,
    Customer_Name,
    Segment,
    City,
    State,
    Country,
    Region,
    Ship_Mode
FROM silver.sales_data_cleaned

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.sales_dates
AS SELECT
  Order_ID,
  Agent_ID
FROM silver.sales_data_cleaned

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.total_commissions
AS
SELECT
  Agent_Name,
  Agent_ID,
  Product_Category,
  SUM(Sales) AS Total_Sales,
  SUM(Commission) AS Total_Commission
FROM (
  SELECT 
    s.Order_ID,
    s.Product_Category,
    s.Sales,
    a.Agent_ID,
    a.Agent_Name,
    a.City,
    a.State,
    a.Country,
    ac.Commission_Percentage,
    (s.Sales * ac.Commission_Percentage / 100) AS Commission
  FROM silver.sales_data_cleaned s
  JOIN bronze.agent a
    ON s.Agent_ID = a.Agent_ID
  JOIN bronze.agent_commissions ac
    ON s.Agent_ID = ac.Agent_ID
) AS AgentCommissions
GROUP BY 
Agent_ID, Agent_Name, Product_Category

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS gold.fact_sales
AS
SELECT 
    d.Order_ID,
    t.Total_Sales AS Price,
    p.Product,
    o.Order_Priority,
    m.Ship_Mode,
    s.Customer_ID
FROM gold.sales_dates d
INNER JOIN gold.customer_data s ON s.Order_ID = d.Order_ID
INNER JOIN gold.total_commissions t ON t.Agent_ID = d.Agent_ID
INNER JOIN gold.sales_products p ON p.Product_Category=t.Product_Category
INNER JOIN gold.sales_shipmode m ON m.Ship_Mode= s.Ship_Mode
INNER JOIN gold.OrderPriority o ON o.Order_ID=d.Order_ID;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
