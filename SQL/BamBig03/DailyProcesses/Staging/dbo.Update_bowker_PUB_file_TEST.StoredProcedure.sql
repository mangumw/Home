USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Update_bowker_PUB_file_TEST]    Script Date: 8/19/2022 3:41:18 PM ******/
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
CREATE PROCEDURE [dbo].[Update_bowker_PUB_file_TEST]
AS

--- append bibliographic_bowker_records with new records ---
INSERT INTO [BKL400].[BKL400].[MM4D4LIB].[BIPPUBUPD]
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
           ,0
FROM dssdata..Bowker_Publisher




GO
