USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Rpt_I_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Rpt_I_Report]
@buyer char(30)
as
declare @strsql Nvarchar(1000)
select @strsql = 'Select * from  ReportData.dbo.rpt_I_Report '
if @buyer <> '<All>'
  select @strsql = @Strsql + 'Where BAM_Buyer = ' + + '''' + @buyer + '''' 

EXEC sp_executesql @strsql

GO
