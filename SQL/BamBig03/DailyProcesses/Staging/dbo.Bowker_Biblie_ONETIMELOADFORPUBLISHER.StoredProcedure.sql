USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Bowker_Biblie_ONETIMELOADFORPUBLISHER]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Leslie Adams>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- changes for new BOWKER Format
-- =============================================
CREATE PROCEDURE [dbo].[Bowker_Biblie_ONETIMELOADFORPUBLISHER]
AS

--

--- update media indicator ---

TRUNCATE TABLE TMP_LOAD..[2013_05_10_ONE_TIME_BOWKER_LOAD]

INSERT INTO TMP_LOAD..[2013_05_10_ONE_TIME_BOWKER_LOAD]
([ItemRecordNumber],
	[PUBIMP] ,
    [PublisherName] ,	
    [PublisherRecordNumber] ,
	[ImprintRecordNumber] )

SELECT 
ITEMRECORDNUMBER,
' ',
ISNULL(CAST(publishername as varchar(45)),''),
ISNULL(CAST(publisherrecordnumber AS int),''),
ISNULL(CAST(imprintrecordnumber AS INT),'') 
FROM DSSDATA..BOWKER_BIBLIO
	

update TMP_LOAD..[2013_05_10_ONE_TIME_BOWKER_LOAD]
set PUBIMP = (select distinct ISNULL(CAST(companyname as varchar(45)),' ') from dssdata..Bowker_Publisher b
    where imprintrecordnumber = b.CompanyRecordNumber and imprintrecordnumber <>'')


INSERT INTO [BKL400].[BKL400].[MM4D4LIB].[BIPPUBTMP]
(RECORD,
PUBIMP,
PUBNME,
PUBRCD,
IMPRCD)

SELECT 
ITEMRECORDNUMBER,
ISNULL(CAST(pubimp as varchar(20)),'') ,
ISNULL(CAST(publishername as varchar(20)),''),
ISNULL(CAST(publisherrecordnumber AS int),''),
ISNULL(CAST(imprintrecordnumber AS INT),'') 
FROM TMP_LOAD..[2013_05_10_ONE_TIME_BOWKER_LOAD]
















GO
