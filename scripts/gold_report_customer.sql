-- Customer Report

CREATE VIEW gold.report_customers AS

WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ' ,c.last_name) AS customer_name,
        DATEDIFF (YEAR, c.birth_date, GETDATE()) as customer_age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
)

, customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        CAST(customer_age AS INT) as customer_age,
        COUNT (DISTINCT order_number) as total_orders,
        SUM (sales_amount) as total_sales,
        SUM (quantity) as total_quantity,
        COUNT (DISTINCT product_key) as total_products,
        MAX (order_date) as last_order_date,
        DATEDIFF (month, MIN(order_date), MAX(order_date)) as lifesspan
    FROM base_query
    GROUP BY customer_key, customer_number,customer_name,customer_age
) 

SELECT
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    CASE WHEN customer_age < 20 THEN 'Under 20'
         WHEN customer_age BETWEEN 20 and 30 THEN '20-30'
         WHEN customer_age BETWEEN 30 AND 40 THEN '30-40'
         WHEN customer_age BETWEEN 40 and 50 THEN '40-50'
         WHEN customer_age BETWEEN 50 and 60 THEN '50-60'
         ELSE 'Above 60'
    END age_group,
    CASE WHEN lifesspan > 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifesspan >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New Customer'
        END customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) as recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifesspan,
    CASE WHEN total_sales = 0 THEN 0
         ELSE total_sales / total_orders 
    END avg_order_value,
    CASE WHEN lifesspan = 0 THEN total_sales
         ELSE total_sales / lifesspan
    END avg_monthly_spend
FROM customer_aggregation
