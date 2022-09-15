SELECT RDSTOR AS StoreNumber,
       RDCEN AS TransactionCentury,
       to_date(char(LPAD(RDDATE,6,0)),'YYMMDD') TransactionDate,
       RDREG AS RegisterNumber,
       RDTIL AS TillNumber,
       RDLIN AS ReportLineNo,
       RDDEPT AS DepartmentNo,
       RDAMT AS ReportAmount,
       RDDATE as DATE
    FROM MM4R4LIB.CSHRED
--    WHERE RDDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)