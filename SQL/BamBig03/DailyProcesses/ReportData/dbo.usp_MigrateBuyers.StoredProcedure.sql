USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateBuyers]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 11/18/2021
-- Description: Migrate Buyer Information
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateBuyers]

AS
BEGIN
truncate table StagingBuyers
truncate table buyers

insert into StagingBuyers (
BuyerNumber, BuyerName, BuyerStartDateCenCode, BuyerStartDate, PhoneExt, DandWIntials, SrBuyerCode, SrBuyerEmail, AsstBuyerCode, AsstBuyerEmail
)
select 
BuyerNumber, BuyerName, BuyerStartDateCenCode, BuyerStartDate, PhoneExt, DandWIntials, SrBuyerCode, SrBuyerEmail, AsstBuyerCode, AsstBuyerEmail
from openquery (bkl400, 'Select
BYRNUM AS BuyerNumber,
BYRNAM AS BuyerName,
BYRSCN AS BuyerStartDateCenCode,
BYRSDT AS BuyerStartDate,  
BYREXT AS PhoneExt,
BYRDWI AS DandWIntials,
BYRSBC AS SrBuyerCode,
BYRSEM AS SrBuyerEmail,
BYRASC AS AsstBuyerCode,
BYRASM AS AsstBuyerEmail
FROM MM4R4LIB.TBLBYR')

insert into Buyers (
BuyerNumber, BuyerName, BuyerStartDateCenCode, 
BuyerStartDate, PhoneExt, DandWIntials, SrBuyerCode, SrBuyerEmail, AsstBuyerCode, AsstBuyerEmail
)

select 
BuyerNumber, BuyerName, BuyerStartDateCenCode, case  when LEN(BuyerStartDate) = 5 then '0'+BuyerStartDate 
when LEN(BuyerStartDate) = 6 then COALESCE(TRY_CONVERT(DATE, BuyerStartDate, 105), TRY_CONVERT(DATE, BuyerStartDate, 120))
else null end as BuyerStartDate, PhoneExt, DandWIntials, SrBuyerCode, SrBuyerEmail, AsstBuyerCode, AsstBuyerEmail
from StagingBuyers



END
GO
