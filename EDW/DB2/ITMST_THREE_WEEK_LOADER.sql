SELECT IMITNO AS ItemNumber,
       IMITD1 AS ItemDescription1,
       IMITD2 AS ItemDescription2,
       IMUNM1 AS UnitofMeasure1,
       IMUNM2 AS UnitofMeasure2,
       IMUNM3 AS UnitofMeasure3,
       IMUMC1 AS UMConversion1,
       IMUMC2 AS UMConversion2,
       IMDUMC AS DefaultUMCode,
       IMPRUM AS PricingUM,
       IMPUMC AS PricingUnitofMeasureConversion,
       IMSCH1 AS UnitofMeasureSurcharge1,
       IMSCH2 AS UnitofMeasureSurcharge2,
       IMSCH3 AS UnitofMeasureSurcharge3,
       IMSCC1 AS SurchargeCode1,
       IMSCC2 AS SurchargeCode2,
       IMSCC3 AS SurchargeCode3,
       IMUWT1 AS UnitWeightUM1,
       IMUWT2 AS UnitWeightUM2,
       IMUWT3 AS UnitWeightUM3,
       IMITCL AS ItemClass,
       IMITSC AS ItemSubclass,
       IMPRCL AS PriceClass,
       IMQBCL AS QuantityBreakClass,
       IMMFNO AS ManufacturersItemNumber,
       IMCCH1 AS ContainerCharge1,
       IMCCH2 AS ContainerCharge2,
       IMCCH3 AS ContainerCharge3,
       IMLPR1 AS ListPrice1,
       IMLPR2 AS ListPrice2,
       IMLPR3 AS ListPrice3,
       IMLPR4 AS ListPrice4,
       IMLPR5 AS ListPrice5,
       IMTXCD AS TaxableCode,
       IMREVS AS ReuseCode,
       IMBOCD AS BackorderCode,
       IMCDCD AS AllowCashDiscountCode,
       IMTDSC AS AllowTradeDiscountCode,
       IMSUSP AS SuspendCode,
       IMMC01 AS MiscellaneousCode1,
       IMMC02 AS MiscellaneousCode2,
       IMMC03 AS MiscellaneousCode3,
       IMCONO AS CompanyNumber,
       IMUPIN AS UpdateInventoryCode,
       IMRKCD AS RankingCode,
       IMADCC AS DateAddedCentury,
       CASE IMADCC
           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IMADDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IMADDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS DateAdded,
       IMLMCC AS DateOfLastMaintCentury,
       CASE IMLMCC
           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IMLMDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IMLMDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS DateOfLastMaint,
       IMCTWT AS CatchWeightCode,
       IMITGL AS ItemGLCode,
       IMLCCL AS LocationClassCode,
       IMFL02 AS CharacterFillerField2,
       IMINUS AS InUseWS,
       IMFETX AS FederalExciseTaxAmount,
       IMVNNO AS VendorNumber,
       IMBMTP AS BillofMaterialType,
       IMNODC AS NumberofDecimals,
       IMLOS1 AS LocationSize1,
       IMLOS2 AS LocationSize2,
       IMLOS3 AS LocationSize3,
       IMWMCD AS WHMgmtCode,
       IMEXDR AS ExpirationDateReqdFlag,
       IMLSIV AS ShowLotSerialonInvoice,
       IMUS15 AS CharacterUserArea15,
       IMRSCD AS ProcuctRestrictionCode,
       IMMSCC AS MSDSCentury,
       CASE IMMSCC
           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IMMSDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IMMSDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS MSDSDate,
       IMITXC AS ItemTaxClass,
       IMRBCL AS RebateClass,
       IMUS5A AS UserField1,
       IMUS5B AS UserField2,
       IMUS5C AS UserField3,
       IMUS5D AS UserField4,
       IMUS5E AS UserField5,
       IMUS5F AS UserField6,
       IMSAUM AS InquiryUM,
       IMRPUM AS ReportingUM,
       IMIGID AS ItemEIDGroup,
       IMEXDF AS ExtendedDescriptionFlag,
       IMPDID AS ProductID,
       IMITCT AS ItemContractCode,
       IMBYCL AS BuyerItemClass,
       IMBYSC AS BuyerItemSubClass,
       IMITCM AS ItemCommitmentCode,
       IMMRSK AS SkipMRPProcessing,
       IMHRTC AS HarmonizeTariffCode,
       IMCMOD AS CommodityCode,
       IMUNLT AS UniqueLots
    FROM APLUS2FAW.ITMST
    WHERE IMADDT > (SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)