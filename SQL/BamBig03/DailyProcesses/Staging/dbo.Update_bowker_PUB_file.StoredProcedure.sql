USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Update_bowker_PUB_file]    Script Date: 8/19/2022 3:41:18 PM ******/
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
CREATE PROCEDURE [dbo].[Update_bowker_PUB_file]
AS
--- delete new updated records ---
delete dssdata..bowker_publisher
from tmp_load..bowker_publisher_tmp as a 
inner join dssdata..bowker_publisher as b 
on a.[CompanyRecordNumber] = b.[CompanyRecordNumber]

INSERT INTO [Dssdata].[dbo].[Bowker_Publisher]
           ([CompanyRecordNumber]
           ,[CompanyName]
           ,[ISBNPrefix]
           ,[CompanyEmail]
           ,[CompanyURL]
           ,[Address1Type]
           ,[Address1Street]
           ,[Address1CityCode]
           ,[Address1City]
           ,[Address1State]
           ,[Address1ZIP]
           ,[Address1Country]
           ,[Address1SAN]
           ,[Address1Phone]
           ,[Address1Fax]
           ,[Address2Type]
           ,[Address2Street]
           ,[Address2CityCode]
           ,[Address2City]
           ,[Address2State]
           ,[Address2ZIP]
           ,[Address2Country]
           ,[Address2SAN]
           ,[Address2Phone]
           ,[Address2Fax]
           ,[Load_Date])

select 
[CompanyRecordNumber]
           ,[CompanyName]
           ,[ISBNPrefix]
           ,[CompanyEmail]
           ,[CompanyURL]
           ,[Address1Type]
           ,[Address1Street]
           ,[Address1CityCode]
           ,[Address1City]
           ,[Address1State]
           ,[Address1ZIP]
           ,[Address1Country]
           ,[Address1SAN]
           ,[Address1Phone]
           ,[Address1Fax]
           ,[Address2Type]
           ,[Address2Street]
           ,[Address2CityCode]
           ,[Address2City]
           ,[Address2State]
           ,[Address2ZIP]
           ,[Address2Country]
           ,[Address2SAN]
           ,[Address2Phone]
           ,[Address2Fax]
           ,Load_Date
from tmp_load..bowker_publisher_tmp


--- append bibliographic_bowker_records with new records ---
INSERT INTO [Dssdata].[dbo].[Bowker_Publisher]
           ([CompanyRecordNumber]
           ,[CompanyName]
           ,[ISBNPrefix]
           ,[CompanyEmail]
           ,[CompanyURL]
           ,[Address1Type]
           ,[Address1Street]
           ,[Address1CityCode]
           ,[Address1City]
           ,[Address1State]
           ,[Address1ZIP]
           ,[Address1Country]
           ,[Address1SAN]
           ,[Address1Phone]
           ,[Address1Fax]
           ,[Address2Type]
           ,[Address2Street]
           ,[Address2CityCode]
           ,[Address2City]
           ,[Address2State]
           ,[Address2ZIP]
           ,[Address2Country]
           ,[Address2SAN]
           ,[Address2Phone]
           ,[Address2Fax]
           ,[Load_Date])

select 
[CompanyRecordNumber]
           ,[CompanyName]
           ,[ISBNPrefix]
           ,[CompanyEmail]
           ,[CompanyURL]
           ,[Address1Type]
           ,[Address1Street]
           ,[Address1CityCode]
           ,[Address1City]
           ,[Address1State]
           ,[Address1ZIP]
           ,[Address1Country]
           ,[Address1SAN]
           ,[Address1Phone]
           ,[Address1Fax]
           ,[Address2Type]
           ,[Address2Street]
           ,[Address2CityCode]
           ,[Address2City]
           ,[Address2State]
           ,[Address2ZIP]
           ,[Address2Country]
           ,[Address2SAN]
           ,[Address2Phone]
           ,[Address2Fax]
           ,Load_Date
from tmp_load..bowker_publisher_tmp


INSERT INTO [BKL400].[BKL400].[MM4R4LIB].[BIPPUBUPD]
			(RECORD,
			PUBNAME,
			SNAME,
			URL,
			ADD1TYP,
			ADD1STR,
			ADD1CC,
			ADD1CTY,
			ADD1ST,
			ADD1ZIP,
			ADD1CNT,
			ADD1PHN,
			ADD1FAX,
			ADD2TYP,
			ADD2STR,
			ADD2CC,
			ADD2CTY,
			ADD2ST,
			ADD2ZIP,
			ADD2CNT,
			ADD2PHN,
			ADD2FAX,
			PUTDTE)

select 	 cast([CompanyRecordNumber] as decimal(8,0))
		   ,cast([CompanyName] as varchar(150))
           ,'  ' 
           ,cast([CompanyURL] as varchar(75))
           ,cast([Address1Type] as varchar(8))
           ,cast([Address1Street] as varchar(100))
           ,cast([Address1CityCode] as varchar(20))
           ,cast([Address1City] as varchar(50))
           ,cast([Address1State] as varchar(40))
           ,cast([Address1ZIP] as varchar(10))
           ,cast([Address1Country] as varchar(8))
           ,cast([Address1Phone] as varchar(16))
           ,cast([Address1Fax] as varchar(16))
           ,cast([Address2Type] as varchar(8))
           ,cast([Address2Street] as varchar(100))
           ,cast([Address2CityCode] as varchar(20))
           ,cast([Address2City] as varchar(50))
           ,cast([Address2State] as varchar(40))
           ,cast([Address2ZIP] as varchar(10))
           ,cast([Address2Country] as varchar(8))
           ,cast([Address2Phone] as varchar(16))
           ,cast([Address2Fax] as varchar(16))
           ,cast(Load_date as varchar(8))
FROM tmp_load..Bowker_Publisher_tmp




/******************************************troubleshooing scripts********************************************/
--INSERT INTO [BKL400].[BKL400].[MMR4RLIB].[BIPPUBUPD] (
--RECORD,PUBNAME,SNAME,URL,ADD1TYP,ADD1STR,ADD1CC,ADD1CTY,ADD1ST,ADD1ZIP,ADD1CNT,
--ADD1PHN,ADD1FAX,ADD2TYP,ADD2STR,ADD2CC,ADD2CTY,ADD2ST,ADD2ZIP,ADD2CNT,ADD2PHN,
--ADD2FAX,PUTDTE )


--Select * from 
--insert openquery  (BKL400, 'Select 
--RECORD,PUBNAME,SNAME,URL,ADD1TYP,ADD1STR,ADD1CC,ADD1CTY,ADD1ST,ADD1ZIP,ADD1CNT,
--ADD1PHN,ADD1FAX,ADD2TYP,ADD2STR,ADD2CC,ADD2CTY,ADD2ST,ADD2ZIP,ADD2CNT,ADD2PHN,
--ADD2FAX,PUTDTE 
--from MM4R4LIB.BIPPUBUPD')
--SELECT CompanyRecordNumber
-- ,CompanyName ,'  ' ,CompanyURL ,Address1Type ,Address1Street ,Address1CityCode ,Address1City ,Address1State ,Address1ZIP
-- ,Address1Country ,Address1Phone ,Address1Fax ,Address2Type ,Address2Street ,Address2CityCode ,Address2City ,Address2State
-- ,Address2ZIP ,Address2Country ,Address2Phone ,Address2Fax ,0 as Load_Date
--FROM tmp_load.dbo.Bowker_Publisher_tmp

--select 	 cast([CompanyRecordNumber] as decimal(8,0))
--		   ,cast([CompanyName] as varchar(150))
--           ,'  ' 
--           ,cast([CompanyURL] as varchar(75))
--           ,cast([Address1Type] as varchar(8))
--           ,cast([Address1Street] as varchar(100))
--           ,cast([Address1CityCode] as varchar(20))
--           ,cast([Address1City] as varchar(50))
--           ,cast([Address1State] as varchar(40))
--           ,cast([Address1ZIP] as varchar(10))
--           ,cast([Address1Country] as varchar(8))
--           ,cast([Address1Phone] as varchar(16))
--           ,cast([Address1Fax] as varchar(16))
--           ,cast([Address2Type] as varchar(8))
--           ,cast([Address2Street] as varchar(100))
--           ,cast([Address2CityCode] as varchar(20))
--           ,cast([Address2City] as varchar(50))
--           ,cast([Address2State] as varchar(40))
--           ,cast([Address2ZIP] as varchar(10))
--           ,cast([Address2Country] as varchar(8))
--           ,cast([Address2Phone] as varchar(16))
--           ,cast([Address2Fax] as varchar(16))
--		   ,0



--Select * into tmp_load.dbo.Bowker_Publisher_tmp_02162022 from tmp_load.dbo.Bowker_Publisher_tmp --Xero Records LK
--Select count(*) from tmp_load.dbo.Bowker_Publisher_tmp
--Select * from tmp_load.dbo.Bowker_Publisher_tmp
--Select * into tmp_load.dbo.Bowker_Publisher_tmp_02182022 from tmp_load.dbo.Bowker_Publisher_tmp
--truncate table tmp_load.dbo.Bowker_Publisher_tmp






GO
