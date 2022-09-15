SELECT IASNUM AS StyleVendor,
       ISTYL# AS StyleNumber,
       INUMBR AS SkuNumber,
       ICENT AS FirstActivityCentury,
       CASE ICENT
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IDATE + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IDATE, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS FirstActivityDate,
       IBSPCT AS BackStockPct,
       IBSQTY AS BackStockQty,
       ICHORD AS ChainOrder,
       IPRQTY AS PublisherRunQty,
       IOPFLG AS OutofPrintTitleFlag,
       IPLFLG AS PrivateLabelFlag,
       ISDCDE AS SellDownActivityCode,
       IMPFLG AS ImportFlag,
       IMTH AS Method,
       IMTHPC AS MethodPercent,
       IPUBC AS PublisherCost,
       IPBPCT AS PublisherCostPercent,
       ITMDW AS DWItemnumber,
       ITMCVT AS Converteditem,
       ISTSCN AS StatusChangeCentury,
       CASE ISTSCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(ISTSDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(ISTSDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS StatusChangeDate,
       ITYPCN AS TypeChangeCentury,
       CASE ITYPCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(ITYPDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(ITYPDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS TypeChangeDate,
       IENTCN AS ItemEntryCentury,
       CASE IENTCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IENTDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IENTDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS ItemEntryDate,
       IMGRUP AS GroupDist,
       IMLTAD AS LimitAddGroup,
       IMLOTP AS LOFLAG,
       IMLOGG AS LOGRPOFGRPS,
       IMLOST AS LOSTORE,
       INLORD AS InitialOrderQuantity,
       IEXRCN AS ExpectedReceiptCentury,
       CASE IEXRCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IEXRDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IEXRDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS ExpectdReceiptDate,
       INLALC AS InitialAllocQuantity,
       INLSTR AS InitialStrength,
       INLSTK AS InitialStockto,
       IMNTBY AS LastMaintainedby
    FROM MM4R4LIB.INVMSTE
    WHERE IDATE > (SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)