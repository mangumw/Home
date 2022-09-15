USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreBatchItemReportBatch1]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/27/2021
-- Description:	Emails Bacth Item Listing to the stores for Bacth One
-- =============================================


CREATE PROCEDURE [dbo].[usp_StoreBatchItemReportBatch1] 

--@Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
declare @command_string varchar(150)
--SET @command_string = 'C:\sql_python\python.exe C:\sql_python\bam_sql_mailer.py SCC.dbo.usp_StoreBatchItemReportBatch1_q ' + CONVERT(varchar(12), @Store)

SET @command_string = 'C:\sql_python\python.exe C:\sql_python\bam_sql_mailer.py SCC.dbo.usp_StoreBatchItemReportBatch1_q 216'

-- Chris this calls a python script that calls a stored proc with the parameter for that proc 
EXEC xp_cmdshell @command_string;
END

GO
