SELECT CSSTOR AS StoreNumber,
       CSCEN AS TransactionCentury,
       TIMESTAMP_FORMAT(CHAR(CSDATE), 'YYMMDD') AS TransactionDate,
       CSREG# AS RegisterNumber,
       CSROLL AS RollOverNumber,
       CSTRN# AS TransactionNumber,
       CSTIME AS TransactionTime,
       CSTTYP AS TransactionType,
       CSTAMT AS TransactionAmount,
       CSTTND AS TenderAmount,
       CSTSTS AS Status,
       CSHLTE AS Highlight,
       CSCSH# AS CashierNumber,
       CSTIL AS TillNumber,
       CSSLPR AS SalespersonNo,
       CSATYP AS AcctType,
       CSACCT AS AccountNumber,
       CSSRSN AS ReasonCode,
       CSSOSP AS OriginalSalesperson,
       CSSOST AS OriginalStore,
       CSCUST AS CustomerNumber,
       to_date(CHAR(CSPDTE), 'YYYYMMDD') AS ProcessDate
    FROM MM4R4LIB.CSHSUM
    WHERE CSPDTE >= (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1095
                FROM SYSIBM.SYSDUMMY1)

 