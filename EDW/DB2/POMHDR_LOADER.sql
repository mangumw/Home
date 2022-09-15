SELECT PONUMB AS PONumber,
       POBO# AS BackOrderNumber,
       POVNUM AS VendorNumber,
       POTRMS AS TermsCode,
       POTIND AS DatingCalcFrom,
       POSTAT AS Status,
       POTYPE AS Type,
       PODEST AS Destination,
       POSTOR AS StoreIfStoreOrder,
       POADYN AS ADPO,
       PODMTH AS DistMethod,
       POALBO AS AllowBackorder,
       POCONF AS Confirmed,
       POPHON AS PhoneOrder,
       POBUYR AS BuyerNumber,
       PODPT AS DepartmentNo,
       POSDPT AS SubDeptNo,
       POTHER AS OtherVendor,
       POFPCD AS FrtPolicyCode,
       POFOB AS FOB,
       POSHP1 AS ShipVia1,
       POSHP2 AS ShipVia2,
       POSHPP AS ShippingPoint,
       POSHPC AS ShippingComments,
       POECEN AS EntryDateCenturyCode,
       CASE POECEN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POEDAT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POEDAT, 6, 0)), 'YYMMDD')
       END AS EntryDate,
       POSCEN AS ShipDateCenturyCode,
       CASE POSCEN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POSDAT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POSDAT, 6, 0)), 'YYMMDD')
       END AS ShipDate,
       POCCEN AS CancelDateCenturyCode,
       CASE POCCEN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POCDAT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POCDAT, 6, 0)), 'YYMMDD')
       END AS CancelDate,
       PORCEN AS ReceiptDateCenturyCode,
       CASE PORCEN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(PORDAT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(PORDAT, 6, 0)), 'YYMMDD')
       END AS ReceiptDate,
       POLCCN AS LastChangeDateCenturyCode,
       CASE POLCCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POLCHG + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POLCHG, 6, 0)), 'YYMMDD')
       END AS LastChangeDate,
       PORFRQ AS ReviewFreqDays,
       POLEAD AS PlanLeadDays,
       POORIG AS PointofOrigin,
       PONOT1 AS PONote1,
       PONOT2 AS PONote2,
       PONOT3 AS PONote3,
       POCOST AS TotalPOCost,
       POVAT AS TotalPOVat,
       PORETL AS TotalPORetail,
       POCASE AS TotalPOCases,
       POUNTS AS TotalPOUnits,
       POWGHT AS TotalPOWeight,
       POTARP AS TarpCharge,
       POSTOP AS StopoverCharge,
       POSKID AS SkidCharge,
       POOTH$ AS OtherChgAmt,
       POOTHP AS OtherChgPercent,
       POBTCH AS BatchCount,
       PORRET AS AmountRecRetail,
       PORVAT AS AmountRecVat,
       PORCST AS AmountRecCost,
       POTPLT AS TotalPallets,
       POCUBE AS TotalCube,
       POPDCN AS PushDownDateCenturyCode,
       CASE POPDCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POPDWN + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POPDWN, 6, 0)), 'YYMMDD')
       END AS PushDownDate,
       SHPNUM AS ShipPointNumber,
       POPYCN AS PayDateDateCenturyCode,
       CASE POPYCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(POPYDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(POPYDT, 6, 0)), 'YYMMDD')
       END AS PayDate,
       POBYTP AS UMType,
       POMALS AS TotSkuLevelAlw,
       POMALV AS TotVendorLevelAlw,
       POMSPO AS MasterPONumber,
       POMSBO AS MasterBONumber,
       POLOAD AS POLoadNumber,
       POMCRT AS ConversionRate,
       POMCCN AS RateEffectiveCentury,
       CASE POMCCN
           WHEN 0 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(POMCDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 1 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(POMCDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS RateEffectiveDate,
       POQCKE AS QuickEntryFlag,
       POMTYP AS MultLoType,
       PO850F AS CreateEDI850,
       PO860F AS CreateEDI860,
       POTPID AS ImportDomestic,
       POPUB AS Publisher
    FROM MM4R4LIB.POMHDR
--    WHERE POEDAT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)