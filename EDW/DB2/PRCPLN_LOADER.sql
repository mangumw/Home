SELECT PLNITM AS ItemNumber,
       PLNLVL AS ChangeCodeLevel,
       PLNSTR AS StoreNumber,
       PLNVND AS VendorNumber,
       PLNSTY AS StyleNumber,
       PLNCCN AS StartDateCentCode,
       CASE PLNCCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(PLNCDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(PLNCDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS TheEffectiveDatePriceChange,
       PLNTYP AS ThePriceEventType,
       PLNFLG AS ISCurrentStatus,
       PLNEVT AS PriceEventNo,
       PLNAMT AS NewPrice,
       PLNMLT AS PriceMultiple,
       PLNMXM AS MixMatchGroup,
       PLNQTY AS BuyQuantity,
       PLNQTV AS BuyValue,
       PLNQTT AS BuyValueType,
       PLNQND AS QtyEndValue,
       PLNEQM AS QuantityBreak,
       PLNACN AS EndDateCentCode,
       CASE PLNACN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(PLNADT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(PLNADT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS EndingDatePricingRecord,
       PLNREC AS RecordType,
       PLNPYN AS IsProcessed,
       PLNHST AS IsHistory,
       PLNNCN AS NotifyStartCentCode,
       CASE PLNNCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(PLNNDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(PLNNDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS NotifyStartDate,
       PLNECN AS NotifyEndEndCent,
       CASE PLNECN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(PLNEDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(PLNEDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS NotifyEndDate,
       PLNCOV AS ApplyCSDOverAD,
       PLNLOV AS ApplyLocOverrideAD
    FROM MM4R4LIB.PRCPLN
    WHERE PLNNDT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)
    GROUP BY PLNITM, 
       PLNLVL,
       PLNSTR,
       PLNVND,
       PLNSTY,
       PLNCCN,
       PLNCCN,
       PLNCDT,
       PLNTYP,
       PLNFLG,
       PLNEVT,
       PLNAMT,
       PLNMLT,
       PLNMXM,
       PLNQTY,
       PLNQTV,
       PLNQTT,
       PLNQND,
       PLNEQM,
       PLNACN,
       PLNACN,
       PLNREC,
       PLNPYN,
       PLNHST,
       PLNNCN,
       PLNECN,
       PLNCOV,
       PLNLOV,
       PLNADT,
       PLNNDT,
       PLNEDT