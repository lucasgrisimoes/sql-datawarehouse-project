/*
COMO IMPORTAR CSV COM DOCKER NO MAC OS
- Suba o arquivo no Docker usando o terminal e escrevendo 'docker cp <caminho_do_arquivo> <IDcontainerDocker> :/<nome_documento>
- No SQL referencie como a última parte, ou seja: :/<nome_documento>
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY

        PRINT '============================'
        PRINT 'Loading Bronze Layer'
        PRINT '============================'

        PRINT '----------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '----------------------------'

        SET @start_time = GETDATE()

        TRUNCATE TABLE bronze.crm_cust_info

        BULK INSERT bronze.crm_cust_info
        FROM '/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        ----------------------------

        TRUNCATE TABLE bronze.crm_prd_info

        BULK INSERT bronze.crm_prd_info
        FROM '/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        --------------------------

        TRUNCATE TABLE bronze.crm_sales_details

        BULK INSERT bronze.crm_sales_details
        FROM '/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE()  
        PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'

        PRINT '----------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '----------------------------'

        SET @start_time = GETDATE()

        --------------------------

        TRUNCATE TABLE bronze.erp_cust_az12

        BULK INSERT bronze.erp_cust_az12
        FROM '/cust_az12'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        --------------------------

        TRUNCATE TABLE bronze.erp_loc_a101

        BULK INSERT bronze.erp_loc_a101
        FROM '/LOC_A101'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        --------------------------

        TRUNCATE TABLE bronze.erp_px_cat_g1v2

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/CAT_G1V2'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

    SET @end_time = GETDATE()
    PRINT 'Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
    PRINT ''

    END TRY
    BEGIN CATCH
        PRINT '======================'
        PRINT 'Error occured during loading Bronze Layer'
        PRINT 'Error message' + ERROR_MESSAGE()
        PRINT '======================'
    END CATCH
END

EXEC bronze.load_bronze
