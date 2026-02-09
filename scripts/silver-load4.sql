-- ===================================================
-- Identificando erros na tabela bronze.erp_cust_az12
-- ===================================================

-- Verificando as datas de nascimento

SELECT 
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Checando valores da coluna gen

SELECT DISTINCT gen
FROM bronze.erp_cust_az12

-- =========================================
-- Tabela Final Silver (sem erros)
-- =========================================

TRUNCATE TABLE silver.erp_cust_az12

INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)

SELECT 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    END AS cid,

    CASE WHEN bdate > GETDATE() THEN NULL
         ELSE bdate
    END AS bdate,

    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         ELSE 'n/a'
    END AS gen

FROM bronze.erp_cust_az12








-- ===================================================
-- Identificando erros na tabela bronze.erp_cust_az12
-- ===================================================

-- Identificando valores distintos e retirando quebra de linha (arrow/seta)

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

UPDATE bronze.erp_loc_a101
SET cntry = REPLACE(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''), CHAR(9), '')

-- =========================================
-- Tabela Final Silver (sem erros)
-- =========================================

INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)

SELECT
    REPLACE(cid, '-', ''),
    
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101








-- ===================================================
-- Identificando erros na tabela bronze.erp_cust_az12
-- ===================================================

-- Verificando as datas de nascimento

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maitenance != TRIM(maitenance)

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

-- =========================================
-- Tabela Final Silver (sem erros)
-- =========================================

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maitenance
)

SELECT 
    id,
    cat,
    subcat,
    maitenance
FROM bronze.erp_px_cat_g1v2
