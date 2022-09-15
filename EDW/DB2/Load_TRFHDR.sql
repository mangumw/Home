SELECT TRFBCH AS TransferBatchNumber,
       TRFSTS AS TransferStatusOptions,
       TRFTYP AS TransferType,
       TRFPTY AS TransferPriorityCodes,
       TRFFLC AS FromStoreorWarehouse,
       TRFTLC AS ToStoreorWarehouse,
       TRFICN AS InitiationDateCenturyCode,
--       to_date(CHAR(LPAD(TRFIDT, 6, 0)), 'YYMMDD') as InitiationDate,
       CASE TRFICN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(TRFIDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(TRFIDT, 6, 0)), 'YYMMDD')
       END AS InitiationDate,
       TRFBCN AS ShipbyDateCenturyCode,
       CASE TRFBCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(TRFBDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(TRFBDT, 6, 0)), 'YYMMDD')
       END AS ShipbyDate,
--       to_date(CHAR(LPAD(TRFBDT, 6, 0)), 'YYMMDD') AS ShipByDate,
       TRFSCN AS ShippingDateCenturyCode,
       CASE TRFSCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(TRFSDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(TRFSDT, 6, 0)), 'YYMMDD')
       END AS ShippingDate,
--       to_date(CHAR(LPAD(TRFSDT, 6, 0)), 'YYMMDD') AS ShippingDate,
       TRFRCN AS ReceivingDateCenturyCode,
       CASE TRFRCN
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(TRFRDT + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(TRFRDT, 6, 0)), 'YYMMDD')
       END AS RecvDate,
       TRFINS AS SpecialInstructionsLine,
       TRFDLC AS DefaultWarehouseSlot,
       TRFREF AS TransferReferenceNumberPONumberWONumber,
       TRFPYN AS ShippingDocumentPrinted,
       TRINIT AS TransferInitiatedByCode,
       TRFPO# AS PurchaseOrderNumber,
       TRFBO# AS PurchaseOrderBackOrder,
       THTUNT AS TotalUnitsRequestedforallDetail,
       THTPCK AS TotalPicksRequestedforallDetail,
       THTPLT AS TotalPalletsRequestforallDetail,
       THTCTN AS TotalCartonsRequestedforallDetail,
       THTIPK AS TotalInnerPacksRequestedforallDetail,
       THTRTA AS TotalRetailValueofallDetailLines,
       THTCST AS TotalCostValueofallDetailLines,
       THTCUB AS TotalCubeMeasureofallDetailLines,
       THTUNP AS TotalUnitsPickedofallDetail,
       THTPLP AS TotalPalletsPickedofallDetail,
       THTCTP AS TotalCartonsPickedofallDetail,
       THTIPP AS TotalInnerPacksPickedofallDetail,
       THTRTP AS TotalRetailValueofallallPickedDetailLines,
       THTCSP AS TotalCostValueofallPickedDetailLines,
       THTPCU AS TotalCubicMeasureofallPickedDetailLines,
       TRPKLN AS TransferLinestoPick,
       THCYCL AS WarehouseCycleNumber,
       THSCWV AS ScheduleWaveNumber,
       THSCSQ AS ScheduleWaveSequence,
       THSCNM AS ScheduleName,
       TRFXRF AS TransferXRef,
       THCNYN AS ConsolidateTransfer
    FROM MM4R4LIB.TRFHDR
--    WHERE TRFIDT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)

