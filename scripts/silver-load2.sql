-- ===================================================
-- Identificando erros na tabela bronze.crm_prd_info
-- ===================================================

-- Identificando erros na primary key através do COUNT de Primary Key

SELECT 
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Identificando espaços desnecessários na coluna prd_nm
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Identificando preços abaixo de zero ou NULLs

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0  OR prd_cost IS NULL

-- Vendo os valores distintos da coluna prd_line

SELECT DISTINCT prd_line
FROM bronze.

-- Identificando valores inválidos de data (achando valores de início que são maiores que o de final)

SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

-- Arrumando erro de datas inválidas

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS data

FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R' , 'AC-HE-HL-U509')


-- =========================================
-- Tabela Final Silver (sem erros)
-- =========================================

-- Alterando colunas originais da tabela para poder inserir novos dados

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
    DROP TABLE silver.crm_prd_info
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR (50),
    prd_cost INT,
    prd_line NVARCHAR (50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key, 
    prd_nm,
    prd_cost, 
    prd_line,
    prd_start_dt,
    prd_end_dt
)

    SELECT
        prd_id,
        REPLACE (SUBSTRING(prd_key, 1 ,5), '-', '_') as cat_id, -- Deixando igual a tabela do ERP
        SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key, -- Deixando igual a tabela do ERP
        prd_nm,
        ISNULL(prd_cost, 0) as prd_cost, -- Retirando valores NULLs
        
        CASE UPPER(TRIM(prd_line)) -- Retirando abreviações
            WHEN 'M' THEN 'Moutain'
            WHEN 'R' THEN 'Road'
            WHEN 'T' THEN 'Touring'
            WHEN 'S' THEN 'other sales'   
            ELSE  'Unknown'
        END AS prd_line,

        CAST (prd_start_dt as DATE) as prd_start_dt,
        CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info


-- ===================================================
-- Identificando erros na tabela silver.crm_prd_info
-- ===================================================
-- Expectativa: Zero Resultados

-- Identificando erros na primary key através do COUNT de Primary Key

SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Identificando espaços desnecessários na coluna prd_nm
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Identificando preços abaixo de zero ou NULLs

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0  OR prd_cost IS NULL

-- Vendo os valores distintos da coluna prd_line

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Identificando valores inválidos de data (achando valores de início que são maiores que o de final)

SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt
