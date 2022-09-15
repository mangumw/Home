SELECT NIREAS AS ReasonCode,
       INUMBR AS SkuNumber,
       ITMDW AS DWItemNumber,
       NIACTV AS ActiveFlag,
       NIPGMN AS ProgramName,
       NIUSER AS User,
       NICENT AS LastUpdateCentury,
       CASE NICENT
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(NIDATE + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(NIDATE, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS LastUpdateDate,
       TIME(to_date(DIGITS(CAST(NITIME AS DEC(6, 0))), 'HH24MISS')) AS LastUpdateTime
    FROM MM4R4LIB.INVNRI
--    WHERE NIDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1  FROM SYSIBM.SYSDUMMY1)