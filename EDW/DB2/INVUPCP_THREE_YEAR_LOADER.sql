SELECT IUPC AS UPCNumber,
       IUPCCD AS UPCType,
       a.INUMBR AS SkuNumber,
       IUSTYL AS StyleNumber,
       IUASN AS StyleVendor,
       IUPRT# AS VendorPartNo,
       IUVND AS Vendor,
       IUPPDA AS PrepricedAmount,
       IUPPPO AS PrepricedPercentOff,
       IUPPDO AS PrepricedAmtOff,
       ICENT AS FirstActivityCentury,
       case ICENT 
        when 0 then varchar_format(timestamp_format(char(IDATE+19000000), 'YYYYMMDD'), 'YYYYMMDD')
        when 1 then varchar_format(timestamp_format(char(LPAD(IDATE,6,0)),'YYMMDD'),'YYMMDD') end  AS FirstActivityDate,
        ISTSCN AS StatusChangeCentury,
        case ISTSCN 
        when 0 then varchar_format(timestamp_format(char(ISTSDT+19000000), 'YYYYMMDD'), 'YYYYMMDD')
        when 1 then varchar_format(timestamp_format(char(LPAD(ISTSDT,6,0)),'YYMMDD'),'YYMMDD') end AS StatusChangeDate
    FROM MM4R4LIB.INVUPCP a
    INNER JOIN MM4R4LIB.INVMSTE b
        ON a.INUMBR = b.INUMBR
   WHERE ISTSDT > (SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)