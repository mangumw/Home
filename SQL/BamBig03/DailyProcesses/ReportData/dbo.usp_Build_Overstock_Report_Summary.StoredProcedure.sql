USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Overstock_Report_Summary]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Overstock_Report_Summary]
as
declare @sd smalldatetime
declare @ed smalldatetime
declare @DaysInVoid float
declare @DaysIntoVoid float
declare @CompPerc float
declare @DaysLeft int
select @sd = MAX(Start_DATE) from reference.dbo.Overstock_Report_Goals
select @ed= MAX(End_DATE) from reference.dbo.Overstock_Report_Goals
select @DaysInVoid = DateDiff(dd,@sd,@ed)
select @DaysIntoVoid = DateDiff(dd,@sd,staging.dbo.fn_DateOnly(Getdate()))
select @DaysLeft = @DaysInVoid - @DaysIntoVoid
select @CompPerc = (@DaysIntoVoid / @DaysInVoid) 
--
truncate table reportdata.dbo.rpt_Overstock_Report
insert into reportdata.dbo.rpt_Overstock_Report
select  t2.Start_Date,
        t2.End_Date,
        t2.Overstock_Desc,
		0 as Region_Number,
		NULL as Region_Name,
		0 as District_Number,
		NULL as District_Name, 
        t2.Store_Number,
		NULL as Store_Name,
        0 as Store_Qty,
        t2.Overstock,
        @CompPerc as CompPerc,
        0 as DailyUnits,0
from	reference.dbo.Overstock_Report_Goals t2 
where	t2.start_date = @sd
--
select  t3.store_number,
		sum(t3.Store_qty) as Ret_Qty
into	#rets
from	reference.dbo.overstock_detail t2,
		reference.dbo.rtvtrn t3
where	t3.sku_number = t2.sku_number
and		t3.store_number = t2.store_number
and		t3.return_date >= @sd
and		t2.start_date = @sd
and		t2.end_date = @ed
group by t3.store_number
order by t3.store_number
--
update  reportdata.dbo.rpt_Overstock_Report
set		Return_Qty = Ret_Qty
from	#rets
where	reportdata.dbo.rpt_Overstock_Report.store_number = #rets.store_number
--
update  reportdata.dbo.rpt_Overstock_Report
set		DailyUnits = (Overstock - Return_Qty) / @DaysLeft
--
update  reportdata.dbo.rpt_Overstock_Report
set		District_Number = reference.dbo.active_stores.District_Number,
		District_Name = reference.dbo.active_stores.District_Name,
		Region_Number = reference.dbo.active_stores.Region_Number,
		Region_Name = reference.dbo.active_stores.Region_Name,
		Store_Name = reference.dbo.active_stores.Store_Name
from	reference.dbo.active_stores
where	reference.dbo.active_stores.Store_number = reportdata.dbo.rpt_Overstock_Report.Store_Number


GO
