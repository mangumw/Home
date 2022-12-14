USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_GCLU]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Update_GCLU]
as
--
delete from dssdata.dbo.GCLU
where MCustNum in (select MCustNum from staging.dbo.tmp_GCLU)
--
INSERT INTO DssData.dbo.GCLU
           (MCustNum
           ,MCustnumInt
           ,MFName
           ,MLName
           ,MTitle
           ,MCompany
           ,MSoundex
           ,MLetterPhrase
           ,MPreferred
           ,MSpecial
           ,MCreatedate
           ,MFitter
           ,MDLNum
           ,MChildren
           ,MCustNumAlt
           ,MsigOther
           ,PSex
           ,PMaritalStat
           ,pbirthdate
           ,PWorkPhoneCo
           ,PWorkPhone
           ,PExtension
           ,PassignStore
           ,PsalesPerson
           ,Premark1
           ,Premark2
           ,PspouseName
           ,PspLetterPhr
           ,PspBirthdate
           ,Panniversary
           ,PclientType
           ,Pincome
           ,Poccupation
           ,Pgeographic
           ,XupdateInd
           ,XlastModdate
           ,XlastSaleUpd
           ,Wcompany
           ,JcustStatus
           ,JhouseHead
           ,JfaxNum
           ,JlastModBy
           ,Last4Phone
           ,InstantCrd
           ,BadChecks
           ,PayTerms
           ,AllowChrg
           ,CrdLimit
           ,Taxable
           ,PORequired
           ,PriceCode
           ,Statusdate
           ,GenericFlag
           ,ReqMgrOvr
           ,TaxExemptID
           ,CustNumExt
           ,MstoreNum
           ,MMName
           ,MnameSuffix
           ,MbusTitle
           ,Creditbal
           ,AltCustNum1
           ,AltCustNum2
           ,AltCustNum3
           ,Register
           ,Tx_No
           ,StId
           ,AllowChk
           ,Email
           ,Expdate1
           ,Expdate2
           ,Expdate3
           ,ArecType
           ,AcustNum
           ,Geographic
           ,Aaddress1
           ,Aaddress2
           ,Aaddress3
           ,Acity
           ,Astate
           ,Acounty
           ,Azip
           ,Acountry
           ,AphoneContr
           ,Aphone
           ,AupdateInd
           ,AfDay
           ,AfMonth
           ,AtDay
           ,AtMonth
           ,PrimAddr
           ,AaSeqNum
           ,AaddrTypeCode
           ,AaddrTechKey
           ,AphoneTypeCode
           ,AphoneCityCode
           ,AphoneExt
           ,AstoreNum
           ,stamp)
    SELECT MCustNum
	  ,Cast(MCustNum as BigInt)
      ,MFName
      ,MLName
      ,MTitle
      ,MCompany
      ,MSoundex
      ,MLetterPhrase
      ,MPreferred
      ,MSpecial
      ,MCreatedate
      ,MFitter
      ,MDLNum
      ,MChildren
      ,MCustNumAlt
      ,MsigOther
      ,PSex
      ,PMaritalStat
      ,pbirthdate
      ,PWorkPhoneCo
      ,PWorkPhone
      ,PExtension
      ,PassignStore
      ,PsalesPerson
      ,Premark1
      ,Premark2
      ,PspouseName
      ,PspLetterPhr
      ,PspBirthdate
      ,Panniversary
      ,PclientType
      ,Pincome
      ,Poccupation
      ,Pgeographic
      ,XupdateInd
      ,XlastModdate
      ,XlastSaleUpd
      ,Wcompany
      ,JcustStatus
      ,JhouseHead
      ,JfaxNum
      ,JlastModBy
      ,Last4Phone
      ,InstantCrd
      ,BadChecks
      ,PayTerms
      ,AllowChrg
      ,CrdLimit
      ,Taxable
      ,PORequired
      ,PriceCode
      ,Statusdate
      ,GenericFlag
      ,ReqMgrOvr
      ,TaxExemptID
      ,CustNumExt
      ,MstoreNum
      ,MMName
      ,MnameSuffix
      ,MbusTitle
      ,Creditbal
      ,AltCustNum1
      ,AltCustNum2
      ,AltCustNum3
      ,Register
      ,Tx_No
      ,StId
      ,AllowChk
      ,Email
      ,Case IsDate(Expdate1)
		When 0 then NULL
		Else Expdate1
		End
      ,Case IsDate(Expdate2)
		When 0 then NULL
		Else Expdate2
		End
      ,Case IsDate(Expdate3)
		When 0 then NULL
		Else Expdate3
		End
      ,ArecType
      ,AcustNum
      ,Geographic
      ,Aaddress1
      ,Aaddress2
      ,Aaddress3
      ,Acity
      ,Astate
      ,Acounty
      ,Azip
      ,Acountry
      ,AphoneContr
      ,Aphone
      ,AupdateInd
      ,AfDay
      ,AfMonth
      ,AtDay
      ,AtMonth
      ,PrimAddr
      ,AaSeqNum
      ,AaddrTypeCode
      ,AaddrTechKey
      ,AphoneTypeCode
      ,AphoneCityCode
      ,AphoneExt
      ,AstoreNum
      ,stamp
  FROM Staging.dbo.tmp_GCLU

update dssdata..gclu
set mcreatedate = '1990-01-01 00:00:00'
where mcreatedate < '1990-01-01' 
or mcreatedate > '2025-01-01'

update dssdata..gclu
set xlastmoddate = '1990-01-01 00:00:00'
where xlastmoddate < '1990-01-01' or xlastmoddate > '2025-01-01'
GO
