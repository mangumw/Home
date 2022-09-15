SELECT RVCONO AS CompanyNumber,
       RVCSNO AS CustomerNumber,
       RVWHID AS WarehouseID,
       RVITNO AS ItemNumber,
       RVRSQT AS QuantityReserved,
       RVUNMS AS UnitofMeasure,
       RVRVCC AS ExpireDateCnty,
       TO_DATE(CHAR(RVRVDT), 'YYMMDD') AS ExpireDate,
--       CASE RVRVCC
--           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(RVRVDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
--           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(RVRVDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
--       END AS ExpireDate,
       RVLMCC AS LastMaintDateCnty,
--       CASE RVLMCC
--           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(RVLMDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
--           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(RVLMDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
--       END AS LastMaintDate,
       TO_DATE(CHAR(RVLMDT), 'YYMMDD') AS LastMaintDate,
       LTRIM(RTRIM(RVCGUS)) AS LastMaintUser,
       TIME(to_date(DIGITS(CAST(RVCHTM AS DEC(6, 0))), 'HH24MISS')) AS LastMaintTime
    FROM APLUS2FAW.CSRSV
--    WHERE RVLMDT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1  FROM SYSIBM.SYSDUMMY1)
