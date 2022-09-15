SELECT STRNUM AS StoreNumber,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(CNTDAT, 8, 0)), 'YYYYMMDD'), 'YYYYMMDD') AS Countdate,
       TCODE AS TypeCode,
       CNTID AS CountID,
       POLLED AS Polled,
       POSTED AS Posted,
       ERRFLG AS ErrorFlag,
       USERID AS ChangedbyUserId,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(CHGDTE, 8, 0)), 'YYYYMMDD'), 'YYYYMMDD') AS ChangedDate,
       SUMFLG AS SummaryFlag,
       FINRPT AS FinalReportSent
    FROM MM4R4LIB.PIESCH