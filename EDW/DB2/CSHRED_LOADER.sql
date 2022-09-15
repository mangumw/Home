SELECT RDSTOR AS StoreNumber,
       RDCEN AS TransactionCentury,
       TIMESTAMP_FORMAT(CHAR(RDDATE), 'YYMMDD') AS TransactionDate,
       RDREG AS RegisterNumber,
       RDTIL AS TillNumber,
       RDLIN AS ReportLineNo,
       RDDEPT AS DepartmentNo,
       RDAMT AS ReportAmount,
       RDDATE as DATE
    FROM MM4R4LIB.CSHRED
    where RDDATE = varchar_format (current date -1 days, 'YYMMDD')
