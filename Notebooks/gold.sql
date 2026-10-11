
CREATE SCHEMA IF NOT EXISTS main.gold;

CREATE OR REPLACE TABLE main.gold.dim_product AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY item, category
    ) AS product_key,
    item,
    category
FROM (
    SELECT DISTINCT
        item,
        category
    FROM main.silver.sales
    WHERE item IS NOT NULL
) p;

CREATE OR REPLACE TABLE main.gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY customer_id
    ) AS customer_key,
    customer_id
FROM (
    SELECT DISTINCT customer_id
    FROM main.silver.sales
    WHERE customer_id IS NOT NULL
) c;

CREATE OR REPLACE TABLE main.gold.dim_date AS
WITH distinct_dates AS (
    SELECT DISTINCT
        TO_DATE(Transaction_Date) AS full_date
    FROM main.silver.sales
    WHERE Transaction_Date IS NOT NULL
)
SELECT
    CAST(DATE_FORMAT(full_date, 'yyyyMMdd') AS INT) AS date_key,
    full_date,
    DAY(full_date) AS day,
    MONTH(full_date) AS month,
    DATE_FORMAT(full_date, 'MMMM') AS month_name,
    QUARTER(full_date) AS quarter,
    YEAR(full_date) AS year,
    DAYOFWEEK(full_date) AS day_of_week,
    DATE_FORMAT(full_date, 'EEEE') AS day_name,
    CASE
        WHEN DAYOFWEEK(full_date) IN (1, 7)
            THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM distinct_dates;

CREATE OR REPLACE TABLE main.gold.dim_channel AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY location, payment_method
    ) AS channel_key,
    location,
    payment_method
FROM (
    SELECT DISTINCT
        Location AS location,
        Payment_Method
    FROM main.silver.sales
    WHERE location IS NOT NULL
      AND Payment_Method IS NOT NULL
) ch;

CREATE OR REPLACE TABLE main.gold.fact_sales AS
SELECT
    s.Transaction_Id,

    c.customer_key,
    p.product_key,
    d.date_key,
    ch.channel_key,

    s.Quantity,
    s.Price_Per_Unit,
    s.Total_Spent AS sales_amount,
    s.Discount_Applied

FROM main.silver.sales s

LEFT JOIN main.gold.dim_customer c
    ON s.Customer_Id = c.customer_id

LEFT JOIN main.gold.dim_product p
    ON s.Item = p.item
   AND s.Category = p.category

LEFT JOIN main.gold.dim_date d
    ON TO_DATE(s.Transaction_Date) = d.full_date

LEFT JOIN main.gold.dim_channel ch
    ON s.Location = ch.location
   AND s.Payment_Method = ch.payment_method;