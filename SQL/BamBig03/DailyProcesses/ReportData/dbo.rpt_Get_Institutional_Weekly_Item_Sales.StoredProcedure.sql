USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Get_Institutional_Weekly_Item_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rpt_Get_Institutional_Weekly_Item_Sales]
@SortOrder varchar(25)
as
declare @strsql nvarchar(255)
set @strsql = 'select * from reportdata.dbo.rpt_institutional_Weekly_Item_Sales '
set @strsql = @strsql + 'Order by ' + @SortOrder
EXEC sp_executesql @strsql

GO
