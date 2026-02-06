/*
COMO IMPORTAR CSV COM DOCKER NO MAC OS
- Suba o arquivo no Docker usando o terminal e escrevendo 'docker cp <caminho_do_arquivo> <IDcontainerDocker> :/<nome_documento>
- No SQL referencie como a última parte, ou seja: :/<nome_documento>
*/

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
