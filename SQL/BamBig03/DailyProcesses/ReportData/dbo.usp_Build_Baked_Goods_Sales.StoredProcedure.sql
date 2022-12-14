USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Baked_Goods_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Baked_Goods_Sales]
as
declare @Start_Date smalldatetime
declare @DOW int
declare @fy int
declare @fp int
declare @FY_Start smalldatetime
declare @FP_Start smalldatetime
select @DOW = day_of_week_number from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(Getdate())
select @Start_Date = staging.dbo.fn_Last_Saturday(getdate())
if @DOW = 1 select @Start_Date = Dateadd(ww,-1,@Start_DAte)
select @Start_Date = dateadd(dd,1,@Start_Date)
select @fy = fiscal_year from reference.dbo.calendar_dim where day_date = @Start_Date
select @fp = fiscal_period from reference.dbo.calendar_dim where day_date = @Start_Date
select @fy_start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy
select @fp_start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy and fiscal_period = @fp
--
select	t1.Store_Number,
		t2.sku as Sku_Number,
		t2.description,
		sum(t1.item_quantity) as WTD_SLSU,
		sum(t1.extended_price) as WTD_SLSD
into	#WTD
from	dssdata.dbo.detail_transaction_history t1,
		reference.dbo.cafe_report_config t2
Where	t1.day_date >= @Start_Date
and		t1.sku_number = t2.sku
and		t2.lvl1cat = 'Fresh Goods'
group by t1.store_number,t2.sku,t2.Description
order by t1.store_number,t2.sku
--
select	t1.Store_Number,
		t2.sku as sku_number,
		t2.description,
		sum(t1.item_quantity) as YES_SLSU,
		sum(t1.extended_price) as YES_SLSD
into	#YES
from	dssdata.dbo.detail_transaction_history t1,
		reference.dbo.cafe_report_config t2
where	t1.day_date = Dateadd(dd,-1,staging.dbo.fn_DateOnly(getdate()))
and		t1.sku_number = t2.sku
and		t2.lvl1cat = 'Fresh Goods'
group by t1.store_number,t2.sku,t2.Description
order by t1.store_number,t2.sku
--
select	t1.Store_Number,
		t2.sku as sku_number,
		t2.description,
		sum(t1.item_quantity) as FP_SLSU,
		sum(t1.extended_price) as FP_SLSD
into	#FP
from	dssdata.dbo.detail_transaction_history t1,
		reference.dbo.cafe_report_config t2
where	t1.day_date >= @fp_Start
and		t1.sku_number = t2.sku
and		t2.lvl1cat = 'Fresh Goods'
group by t1.store_number,t2.sku,t2.Description
order by t1.store_number,t2.sku
--
select	t1.Store_Number,
		t2.sku as sku_number,
		t2.description,
		sum(t1.item_quantity) as fy_SLSU,
		sum(t1.extended_price) as fy_SLSD
into	#FY
from	dssdata.dbo.detail_transaction_history t1,
		reference.dbo.cafe_report_config t2
where	t1.day_date >= @fy_start
and		t1.sku_number = t2.sku
and		t2.lvl1cat = 'Fresh Goods'
group by t1.store_number,t2.sku,t2.Description
order by t1.store_number,t2.sku

truncate table reportdata.dbo.baked_goods_sales
insert into Reportdata.dbo.Baked_Goods_Sales
select	staging.dbo.fn_DateOnly(Getdate()) as Day_Date,
		t1.Region_Number,
		t1.District_Number,
		t1.store_number,
		t2.sku,
		t2.description,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
from	reference.dbo.active_stores t1,
		reference.dbo.cafe_report_config t2
where	t2.lvl1cat = 'Fresh Goods'
------------------------------------------------------------------------------------
update	Reportdata.dbo.Baked_Goods_Sales
set		YES_SLSU = #yes.YES_SLSU,
		YES_SLSD = #YES.YES_SLSD
from	#YES
where	#YES.Sku_Number = Reportdata.dbo.Baked_Goods_Sales.Sku_Number
and		#YES.Store_Number = Reportdata.dbo.Baked_Goods_Sales.Store_Number
--------------------------------------------------------------------------------------------
update	Reportdata.dbo.Baked_Goods_Sales
set		WTD_SLSU = #WTD.WTD_SLSU,
		WTD_SLSD = #WTD.WTD_SLSD
from	#WTD
where	#WTD.Sku_Number = Reportdata.dbo.Baked_Goods_Sales.Sku_Number
and		#WTD.Store_Number = Reportdata.dbo.Baked_Goods_Sales.Store_Number
------------------------------------------------------------------------------------------
update	Reportdata.dbo.Baked_Goods_Sales
set		FP_SLSU = #FP.FP_SLSU,
		FP_SLSD = #FP.FP_SLSD
from	#FP
where	#FP.Sku_Number = Reportdata.dbo.Baked_Goods_Sales.Sku_Number
and		#FP.Store_Number = Reportdata.dbo.Baked_Goods_Sales.Store_Number
------------------------------------------------------------------------------------------
update	Reportdata.dbo.Baked_Goods_Sales
set		FY_SLSU = #FY.FY_SLSU,
		FY_SLSD = #FY.FY_SLSD
from	#FY
where	#FY.Sku_Number = Reportdata.dbo.Baked_Goods_Sales.Sku_Number
and		#FY.Store_Number = Reportdata.dbo.Baked_Goods_Sales.Store_Number
--		
GO
