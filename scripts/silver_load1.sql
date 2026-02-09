-- ===================================================
-- Identificando erros na tabela bronze.crm_cust_info
-- ===================================================

-- Identificando erros na primary key através do COUNT de Primary Key

SELECT 
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id is NULL

-- Vendo quais são os registros em Primary Key com alterações mais antigas

SELECT
*
FROM (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last != 1

-- Vendo espaços não desejados no firstname

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Checando valores 

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

-- =========================================
-- Tabela Final silver.crm_cust_info
-- =========================================

TRUNCATE TABLE silver.crm_cust_info

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE WHEN  UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN   UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE   'Unknown'
    END cst_marital_status,
    
    CASE WHEN  UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN   UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE   'Unknown'
    END cst_gndr,

    cst_create_date
FROM (
    SELECT
    *
    FROM (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t WHERE flag_last = 1
) t

-- =========================================
-- Identificando erros na tabela silver.crm_cust_inf
-- =========================================
-- Expectativa: Sem Resultados

-- Identificando erros na primary key através do COUNT de Primary Key

SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id is NULL

-- Vendo quais são os registros em Primary Key com alterações mais antigas

SELECT
*
FROM (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
    FROM silver.crm_cust_info
) t
WHERE flag_last != 1

-- Vendo espaços não desejados no firstname

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- =========================================
-- Vendo a tabela final Silver
-- =========================================

SELECT *
FROM silver.crm_cust_info
