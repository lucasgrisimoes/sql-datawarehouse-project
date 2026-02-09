-- ===================================================
-- Identificando erros na tabela bronze.crm_sales_details
-- ===================================================

-- Verificando se temos espaços extras em sls_order_num

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_num != TRIM(sls_order_num)

-- Verificando se temos alguma chave de produto não presente na tabela silver.crm_prod_info

SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

-- Checando datas inválidas e arrumando elas

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 

SELECT
    NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0  OR LEN(sls_order_dt) != 8

-- Checando datas inválidas de pedidos

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Checando preços da columa sls_price e arrumando eles

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
      OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
      OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price



-- =========================================
-- Tabela Final Silver (sem erros)
-- =========================================

-- Alterando colunas originais da tabela para poder inserir novos dados

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
    DROP TABLE silver.crm_sales_details
CREATE TABLE silver.crm_sales_details (
    sls_order_num NVARCHAR (50),
    sls_prd_key NVARCHAR (50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dqh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Inserindo novos dados limpos

TRUNCATE TABLE silver.crm_sales_details

INSERT INTO silver.crm_sales_details (
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)

SELECT
    sls_order_num,
    sls_prd_key,
    sls_cust_id,

    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) AS sls_ship_dt,
    CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) AS sls_due_dt,

    CASE WHEN sls_sales IS NULL OR sls_sales <- 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END as sls_sales,

    sls_quantity,

 CASE WHEN sls_price IS NULL OR sls_price <- 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END as sls_price

FROM bronze.crm_sales_details


-- ===================================================
-- Identificando erros na tabela silver.crm_sales_details
-- ===================================================

-- Verificando se temos espaços extras em sls_order_num

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_num != TRIM(sls_order_num)


-- Checando datas inválidas de pedidos

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Checando preços da columa sls_price e arrumando eles

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
      OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
      OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
