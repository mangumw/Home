SELECT a.TRFBCH AS TransferBatchNumber,
       a.TRFFLC AS FromStoreorWarehouse,
       a.TRFTLC AS ToStoreorWarehouse,
       a.INUMBR AS SkuNumber,
       a.ASNUM AS VendorNumber,
       a.IDEPT AS Dept,
       a.ISDEPT AS SubDept,
       a.ICLAS AS Class,
       a.ISCLAS AS SubClass,
       a.TRFREQ AS QtyRequest,
       a.TRFSHP AS QtyShipped,
       a.TRFREC AS QtyReceive,
       a.TRFALC AS QtyAllocate,
       a.TRFSUB AS SubstituteNumber,
       a.TRFSCD AS SubstituteCode,
       a.TRFRLC AS ReceivedWarehouseLocation,
       a.TRFCST AS UnitCost,
       a.TRFRIN AS RetailIn,
       a.TRFROU AS RetailOut,
       a.ICUBE AS Cube,
       substring(a.IVNDP#,1,15) AS VendorsPartNumber,
       a.TRFSTS AS TransferStatusOpt,
       a.TRFTYP AS TransferType,
       a.TRFPTY AS TransferPriorityOpt,
       a.TDCYCL AS WarehouseCycleNumber,
       a.TDSCWV AS ScheduleWaveNumber,
       a.TDSCSQ AS ScheduleWaveSequence,
       a.TDSCNM AS ScheduleName,
       a.TRSVND AS StyleVendor,
       a.TRSTYL AS StyleNumber,
       a.TRSCOL AS ColorCode,
       a.TRSSIZ AS SizeCode,
       a.TRSDIM AS DimensionCode,
       a.TRFDSP AS TransferDiscrepancyFlag,
       a.TDSCQT AS CartonShipQty,
       a.TDRCQT AS CartonReceiveQty,
       a.TDWGHT AS Weight,
       b.TRFICN AS CENTURYCODE,
       CASE TRFICN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(b.TRFIDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(b.TRFIDT, 6, 0)), 'YYMMDD')
       END AS InitiationDate,
       b.TRFBCN AS ShipbyDateCenturyCode,
       CASE TRFBCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(b.TRFBDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(b.TRFBDT, 6, 0)), 'YYMMDD')
       END AS ShipbyDate,
       b.TRFSCN AS ShippingDateCenturyCode,
       CASE TRFSCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(b.TRFSDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(b.TRFSDT, 6, 0)), 'YYMMDD')
       END AS ShippingDate,
       b.TRFRCN AS ReceivingDateCenturyCode,
       CASE TRFRCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(b.TRFRDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(b.TRFRDT, 6, 0)), 'YYMMDD')
       END AS RecvDate
    FROM MM4R4LIB.TRFDTL a
         INNER JOIN MM4R4LIB.TRFHDR b
             ON a.TRFBCH = b.TRFBCH
--WHERE b.TRFRDT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)