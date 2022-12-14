USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Replenishment_model]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Replenishment_model]
(@Last_Saturday smalldatetime,
 @Route varchar(50) )
as
--
truncate table reportdata.dbo.Replen
drop table #LW
drop table #PW

--
-- Key 1 Top 100
--
drop table #Keys
select	top 100
		t1.sku_number,
		sum(Current_Dollars) as SLSD
into	#Keys
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 1
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 3 Top 25
--
truncate table #keys
insert into #Keys
select	top 25
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 3
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 4 Top 300
--
truncate table #keys
insert into #Keys
select	top 300
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 4
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 5 Top 100
--
truncate table #keys
insert into #Keys
select	top 100
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 5
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 5 Top 100
--
truncate table #keys
insert into #Keys
select	top 200
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 6
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 8 Top 50
--
truncate table #keys
insert into #Keys
select	top 50
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 8
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 12 Top 50
--
truncate table #keys
insert into #Keys
select	top 50
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 12
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 13 Top 25
--
truncate table #keys
insert into #Keys
select	top 25
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 13
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 16 Top 25
--
truncate table #keys
insert into #Keys
select	top 25
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 16
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number
--
--
-- Key 58 Top 50
--
truncate table #keys
insert into #Keys
select	top 50
		t1.sku_number,
		sum(Current_Dollars) as SLSD
from	dssdata.dbo.weekly_sales t1,
		dssdata.dbo.card t2
where	day_date = @Last_Saturday
and		t2.Dept = 58
and		t1.sku_number = t2.sku_number
and		t1.sku_number > 99
group by t1.sku_number
order by sum(current_dollars) desc
--
insert into reportdata.dbo.replen
select	t0.Store_Number,
		t1.sku_number,
		t2.ISBN,
		t2.Title,
		t2.pub_code,
		t2.sku_type,
		t2.dept,
		t2.sdept,
		t2.class,
		t2.SR_Buyer,
		t2.buyer,
		t5.Descr,
		t5.day,
		t4.On_Hand,
		t4.On_Order,
		0 as LW_Units,
		0 as PW_Units,
		t2.Warehouse_OnHand,
		t6.Display_Min as Display_Min
from	reference.dbo.active_stores t0,
		#Keys t1,
		dssdata.dbo.card t2,
		reference.dbo.invbal t4,
		Reference.dbo.Delivery_Routes t5,
		reference.dbo.item_display_min t6
where	t2.sku_number = t1.sku_number
and		t4.sku_number = t1.sku_number
and		t4.store_number = t0.store_number
and		t5.store = t0.store_number
and		t5.Route_Name = @Route
and		t5.date >= @Last_Saturday
and		t5.Date <= dateadd(ww,1,@Last_Saturday)
and		t6.store_number = t0.store_number
and		t6.sku_number = t1.sku_number
order by t0.Store_Number,t1.sku_number

select t1.store_number,
		t1.sku_number,
		sum(t2.current_units) as LW_Units
into	#LW
from	reportdata.dbo.replen t1,
		dssdata.dbo.weekly_sales t2
where	t2.store_number = t1.store_number
and		t2.sku_number = t1.sku_number
and		t2.day_date = @Last_Saturday
group by t1.store_number,t1.sku_number
--
select t1.store_number,
		t1.sku_number,
		sum(t2.current_units) as PW_Units
into	#PW
from	reportdata.dbo.replen t1,
		dssdata.dbo.weekly_sales t2
where	t2.store_number = t1.store_number
and		t2.sku_number = t1.sku_number
and		t2.day_date = '11-08-2008'
group by t1.store_number,t1.sku_number
--
Update	Reportdata.dbo.replen
set		Reportdata.dbo.replen.LW_Units = #LW.LW_Units
from	#LW
where	#LW.Store_Number = Reportdata.dbo.replen.Store_Number
and		#LW.Sku_Number = Reportdata.dbo.replen.Sku_Number
--
Update	Reportdata.dbo.replen
set		Reportdata.dbo.replen.PW_Units = #PW.PW_Units
from	#PW
where	#PW.Store_Number = Reportdata.dbo.replen.Store_Number
and		#PW.Sku_Number = Reportdata.dbo.Replen.Sku_Number
--
select * from reportdata.dbo.replen
where Warehouse_OnHand > 0
and On_Hand < (LW_Units * 5)
order by store_number,Dept,SDept,Class




GO
