-- query 1
SELECT
    Region,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(100.0 * SUM(Profit) / SUM(Sales), 2) AS profit_margin_pct,
    COUNT(*) AS order_lines
FROM superstore_data
GROUP BY Region
ORDER BY total_sales DESC;
-- query 2
WITH t AS (
    SELECT *,
        substr("Order Date", -4) || '-' ||
        printf('%02d', CAST(substr("Order Date", 1, instr("Order Date", '/') - 1) AS INTEGER))
        AS order_month
    FROM superstore_data
),
monthly AS (
    SELECT order_month, ROUND(SUM(Sales), 2) AS total_sales
    FROM t
    GROUP BY order_month
)
SELECT
    order_month,
    total_sales,
    ROUND(total_sales - LAG(total_sales) OVER (ORDER BY order_month), 2) AS sales_change,
    ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY order_month))
          / LAG(total_sales) OVER (ORDER BY order_month), 2) AS mom_growth_pct
FROM monthly
ORDER BY order_month;
-- query 3
SELECT
    "Product Name",
    Category,
    "Sub-Category",
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Sales), 2)  AS total_sales,
    COUNT(*) AS times_ordered
FROM superstore_data
GROUP BY "Product Name", Category, "Sub-Category"
ORDER BY total_profit DESC
LIMIT 10;
-- query 4 
SELECT
    "Product Name",
    Category,
    "Sub-Category",
    ROUND(SUM(Profit), 2)  AS total_profit,
    ROUND(AVG(Discount), 3) AS avg_discount,
    COUNT(*) AS times_ordered
FROM superstore_data
GROUP BY "Product Name", Category, "Sub-Category"
ORDER BY total_profit ASC
LIMIT 10;
-- query 5
SELECT
    Category,
    "Sub-Category",
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(100.0 * SUM(Profit) / SUM(Sales), 2) AS profit_margin_pct
FROM superstore_data
GROUP BY Category, "Sub-Category"
ORDER BY Category, total_sales DESC;
-- query 6 
SELECT
    CASE
        WHEN Discount = 0 THEN '0% (no discount)'
        WHEN Discount <= 0.2 THEN '1-20%'
        WHEN Discount <= 0.4 THEN '21-40%'
        ELSE '41%+'
    END AS discount_bracket,
    COUNT(*) AS order_lines,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(100.0 * SUM(Profit) / SUM(Sales), 2) AS profit_margin_pct
FROM superstore_data
GROUP BY discount_bracket
ORDER BY MIN(Discount);
-- query 7
SELECT
    Region,
    Segment,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(DISTINCT "Customer ID") AS customers
FROM superstore_data
GROUP BY Region, Segment
ORDER BY Region, total_sales DESC;
-- query 8
SELECT
    "Customer Name",
    Segment,
    State,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(*) AS orders_placed
FROM superstore_data
GROUP BY "Customer ID"
ORDER BY total_sales DESC
LIMIT 10;
-- query 9
WITH t AS (
    SELECT *,
        substr("Order Date", -4) || '-' ||
        printf('%02d', CAST(substr("Order Date", 1, instr("Order Date", '/') - 1) AS INTEGER)) || '-' ||
        printf('%02d', CAST(substr(substr("Order Date", instr("Order Date", '/') + 1), 1,
               instr(substr("Order Date", instr("Order Date", '/') + 1), '/') - 1) AS INTEGER))
        AS order_date_iso,
        substr("Ship Date", -4) || '-' ||
        printf('%02d', CAST(substr("Ship Date", 1, instr("Ship Date", '/') - 1) AS INTEGER)) || '-' ||
        printf('%02d', CAST(substr(substr("Ship Date", instr("Ship Date", '/') + 1), 1,
               instr(substr("Ship Date", instr("Ship Date", '/') + 1), '/') - 1) AS INTEGER))
        AS ship_date_iso
    FROM superstore_data
)
SELECT
    "Ship Mode",
    ROUND(AVG(julianday(ship_date_iso) - julianday(order_date_iso)), 2) AS avg_days_to_ship,
    COUNT(*) AS order_lines
FROM t
GROUP BY "Ship Mode"
ORDER BY avg_days_to_ship;
