SELECT RDSTOR AS StoreNumber,
       RDCEN AS TransactionCentury,
       RDDATE AS TransactionDate,
       RDREG AS RegisterNumber,
       RDDATE AS DATE,
       TO_DATE(CHAR(RDDATE), 'YYYYMMDD') as TransactionDate,
       RDTIL AS TillNumber,
       RDLIN AS ReportLineNo,
       RDDEPT AS DepartmentNo,
       RDAMT AS ReportAmount
    FROM MM4R4LIB.CSHRED
    --WHERE RDDATE = VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1
    WHERE RDDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1  FROM SYSIBM.SYSDUMMY1)