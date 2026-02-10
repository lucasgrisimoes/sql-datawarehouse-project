-- Product Report

CREATE VIEW gold.report_products AS

WITH base_query AS (

    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

product_Aggregation AS (

    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_Date)) as lifesspan,
        MAX(order_date) as last_sales_date,
        COUNT (DISTINCT order_number) as total_orders,
        COUNT (DISTINCT customer_key) as total_customers,
        SUM (sales_amount) as total_sales,
        SUM (quantity) as total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)) ,1) as avg_selling_price
    FROM base_query

    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost

)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifesspan,
    total_orders,
    total_sales,
    total_quantity
    total_customers,
    avg_selling_price,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    CASE
        WHEN lifesspan = 0 THEN total_sales
        ELSE total_sales / lifesspan
    END AS avg_monthly_revenue
    FROM product_Aggregation
