SELECT RDSTOR AS StoreNumber,
       RDCEN AS TransactionCentury,
       TIMESTAMP_FORMAT(CHAR(RDDATE), 'YYMMDD') AS TransactionDate,
       RDREG AS RegisterNumber,
       RDTIL AS TillNumber,
       RDLIN AS ReportLineNo,
       RDDEPT AS DepartmentNo,
       RDAMT AS ReportAmount
    FROM MM4R4LIB.CSHRED
    WHERE RDDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1
                FROM SYSIBM.SYSDUMMY1)