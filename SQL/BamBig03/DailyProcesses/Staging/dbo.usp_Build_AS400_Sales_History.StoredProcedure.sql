USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_AS400_Sales_History]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_AS400_Sales_History]
as
declare @satdate smalldatetime
select @satdate = staging.dbo.fn_Last_Saturday(getdate())
--
delete from dssdata.dbo.as400_Sales_History where Date = @SatDate
--
insert into dssdata.dbo.AS400_Sales_History
select	substring(date,5,2) + '/' + right(date,2) + '/' + left(date,4) as Day_Date,
		store,
		store_Desc,
		Report_line_id,
		report_line_desc,
		dept,
		dept_desc,
		cast(day_totals as float)/100,
		cast(WTD_Totals as float)/100,
		cast(MTD_Totals as float)/100,
		cast(QTD_Totals as float)/100,
		cast(YTD_Totals as float)/100,
		cast(LY_Day_Totals as float)/100,
		cast(LY_WTD_Totals as float)/100,
		cast(LY_MTD_Totals as float)/100,
		cast(LY_QTD_Totals as float)/100,
		cast(LY_YTD_Totals as float)/100
from staging.dbo.tmp_SLS_Hist







GO
