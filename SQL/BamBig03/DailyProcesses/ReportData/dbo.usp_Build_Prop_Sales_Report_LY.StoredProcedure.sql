USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Prop_Sales_Report_LY]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Prop_Sales_Report_LY]
as
declare @seldate smalldatetime
declare @TY_Start smalldatetime
declare @LY_Start Smalldatetime
declare @LY_End smalldatetime
declare @Fiscal_Year int
--
select @seldate = staging.dbo.fn_Last_Saturday(getdate())
--
select @Fiscal_Year = fiscal_year from reference.dbo.calendar_dim where day_date = @seldate
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @Fiscal_Year = @Fiscal_Year - 2
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @LY_End = dateadd(yy,-1,@seldate)




--
select	t1.Store_Number,
		t1.sku_number,
		sum(t1.Current_Units) as TYYTD_SLSU,
		sum(t1.Current_Dollars) as TYYTD_SLSD
into	#TYYTD
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	t1.day_date >= @TY_Start
and		t1.sku_number = t2.sku_number
and		t2.Coordinate_Group in ('PROMO','PROPP','PROPS','PROMA','CWQ36') 
AND		((T2.Dept) In (4,5))
group by t1.Store_Number,t1.sku_number
--
select	t1.Store_Number,
		t1.sku_number,
		sum(t1.Current_Units) as LYYTD_SLSU,
		sum(t1.Current_Dollars) as LYYTD_SLSD
into	#LYYTD
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	t1.day_date >= @LY_Start and t1.day_date < @TY_Start
and		t1.sku_number = t2.sku_number
and		t2.Coordinate_Group in ('PROMO','PROPP','PROPS','PROMA','CWQ36') 
AND		((T2.Dept) In (4,5))
group by t1.Store_Number,t1.sku_number
--
select	t1.Store_Number,
		t1.sku_number,
		sum(t1.Current_Units) as SLSU,
		sum(t1.Current_Dollars) as SLSD
into	#TY
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	t1.day_date = @seldate
and		t1.sku_number = t2.sku_number
and		t2.Coordinate_Group in ('PROMO','PROPP','PROPS','PROMA','CWQ36') 
AND		((T2.Dept) In (4,5))
group by t1.Store_Number,t1.sku_number
--
truncate table reportdata.dbo.prop_sales
insert into reportdata.dbo.prop_sales
select	t2.store_number,
		t2.sku_number,
		t1.ISBN,
		t1.Title,
		t1.Pub_Code,
		t1.Author,
		t1.SDept_Name,
		t1.sku_type,
		t1.Retail,
		t1.DWCost,
		t1.IDate,
		t1.InTransit,
		t1.BAM_OnHand,
		t1.Warehouse_OnHand,
		t1.Qty_OnOrder,
		t2.SLSD,
		t2.SLSU,
		t3.TYYTD_SLSD,
		t3.TYYTD_SLSU,
		t4.LYYTD_SLSD,
		t4.LYYTD_SLSU
from	dssdata.dbo.card t1, 
		#TY t2,
		#TYYTD t3,
		#LYYTD t4
where	t1.sku_number = t2.sku_number
and		t3.sku_number = t2.sku_number
and		t3.store_number = t2.store_number
and		t4.sku_number = t2.sku_number
and		t4.store_number = t2.store_number

		
GO
