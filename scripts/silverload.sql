EXECUTE silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE()
        PRINT '================================'
        PRINT 'Loading Silver Layer'
        PRINT '================================'

        PRINT '--------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '--------------------------------'    

        -- Tabela silver.crm_cust_info

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data into: silver.crm_cust_info';
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

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'

        -- Tabela silver.crm_prd_info
    
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_prod_info';
        TRUNCATE TABLE silver.crm_prd_info

        PRINT '>> Inserting Data into: silver.crm_cust_info';
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
        
        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'


        -- Tabela silver.crm_sales_details

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details

        PRINT '>> Inserting Data into: silver.crm_sales_details'
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

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'


        PRINT '--------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '--------------------------------' 

        -- Tabela silver.erp_cust_az12

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12

        PRINT '>> Truncating Table: silver.erp_cust_az12';
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

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'

        -- Tabela silver.erp_loc_a101

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101

        PRINT '>> Inserting Data into: silver.erp_loc_a101';
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

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'

        -- Tabela silver.erp_px_cat_g1v2

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
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
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'

        SET @batch_end_time = GETDATE();
        PRINT '--------------------------------'
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time)as NVARCHAR) + ' seconds'
        PRINT '--------------------------------'
    END TRY
    BEGIN CATCH
    PRINT '========================================='
    PRINT 'ERROR OCCURED DURING LOADIN SILVER LAYER'
    PRINT '========================================='
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Number' + CAST(ERROR_NUMBER() as NVARCHAR);
    PRINT 'Error State' + CAST(ERROR_STATE() as NVARCHAR);
    END CATCH
END
