SELECT STRNUM AS StoreNumber,
       STRATT AS AttributeCode,
       STRA01 AS AttributeValue1,
       STRA02 AS AttributeValue2,
       STRA03 AS AttributeValue3,
       STRA04 AS AttributeValue4,
       STRA05 AS AttributeValue5,
       STRA06 AS AttributeValue6,
       STRA07 AS AttributeValue7,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(STEFDT, 8, 0)), 'YYYYMMDD'), 'YYYYMMDD') AS EffectiveDate,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(STENDT, 8, 0)), 'YYYYMMDD'), 'YYYYMMDD') AS EndDate
    FROM MM4R4LIB.TBLSTRA