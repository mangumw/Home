SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYYYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1

(SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)

(SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYYYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)

(SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)

(SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)