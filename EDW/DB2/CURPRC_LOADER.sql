SELECT STORE# AS StoreNumber,
       a.INUMBR AS SkuNumber,
       a.ISBN AS ISBN,
       a.IDEPT AS Department,
       a.ISDEPT AS SubDepartment,
       a.ICLAS AS Class,
       a.ISCLAS AS SubClass,
       CURREG AS CurRegUnitPrice,
       CURRML AS RegularMult,
       CURPOS AS CurPOSUnitPrice,
       CURPML AS POSMultiple,
       CURCST AS CurrentCost,
       IMCENT AS CenturyLastMaint,
       case IMCENT 
        when 0 then varchar_format(timestamp_format(char(IMDATE+19000000), 'YYYYMMDD'), 'YYYYMMDD')
        when 1 then varchar_format(timestamp_format(char(LPAD(IMDATE,6,0)),'YYMMDD'),'YYMMDD') end as DateLastMaint
    FROM MM4R4LIB.CURPRC a
    INNER JOIN MM4R4LIB.INVMST b
        ON a.INUMBR = b.INUMBR
    WHERE IMDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)