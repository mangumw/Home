USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreVarianceReport]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************
--Onhand from tblBatchdetail and actualy scanned tblScanned items
--get difference >1 add items to variance report and have recount done
--get >25$ if Onhand <> to one another add item to variance report
*******************************************/
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/16/2021
-- Description:	Difference between Scanned Items and Not Scanned Items
-- =============================================

CREATE PROCEDURE [dbo].[usp_StoreVarianceReport] @Store int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
declare @command_string varchar(150)
SET @command_string = 'C:\sql_python\python.exe C:\sql_python\bam_sql_mailer.py SCC.dbo.usp_StoreVarianceReport_q ' + CONVERT(varchar(12), @Store)
-- Chris this calls a python script that calls a stored proc with the parameter for that proc 
EXEC xp_cmdshell @command_string;
END

GO
