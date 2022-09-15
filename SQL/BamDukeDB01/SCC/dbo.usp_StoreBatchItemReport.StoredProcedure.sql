USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreBatchItemReport]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/15/2021
-- Description: Detail Report for Batched Items for Store to Scan
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreBatchItemReport] @Store int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
declare @command_string varchar(150)
SET @command_string = 'C:\sql_python\python.exe C:\sql_python\bam_sql_mailer.py SCC.dbo.usp_StoreBatchItemReport_q ' + CONVERT(varchar(12), @Store)
-- Chris this calls a python script that calls a stored proc with the parameter for that proc 
EXEC xp_cmdshell @command_string;
END

GO
