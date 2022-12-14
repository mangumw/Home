USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_void_report_summary_Split]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_void_report_summary_Split]
as
Declare @sd smalldatetime
select @sd = max(Start_Date) from reference.dbo.void_items
--
truncate table staging.dbo.wrk_Void2_Split
insert into staging.dbo.wrk_Void2_Split
select distinct t1.store_number,
		t1.Item_Type,
		t1.grp,
		t1.goal,
		t1.goal_dollars,
		0 as Ret_Qty,
		0 as Ret_Dollars 
from	reference.dbo.void_goals_Split t1
order by t1.store_number,t1.grp
--
truncate table staging.dbo.wrk_Void1_Split
insert into staging.dbo.wrk_Void1_Split
select	t1.grp,
		t1.store,
		t1.OS_Qty,
		t1.sku_number,
		t1.Item_Type,
		isnull(t3.Scan_ID,' ') as Scan_ID,
		isnull(t3.Store_Qty,0) as Ret_Qty,
		t1.pos_price,
		isnull(t3.store_qty,0) * t1.pos_price as Ret_Dollars
from	reference.dbo.void_items t1 left join
		reference.dbo.rtvtrn t3 
on		t3.store_number = t1.store
and		t3.sku_number = t1.sku_number
and 	t3.return_date >= @sd
 join reference.dbo.rtvtrnh t4
On		t4.debit_number = t3.debit_number
and		t4.scan_code <> 'C'
order by t1.store,t1.grp
--
select	t2.grp,
		t1.store_Number,
		t1.sku_number,
		t2.Item_Type,
		t1.Scan_ID,
		t1.Store_Qty as Ret_Qty,
		t2.pos_price,
		t1.store_qty * t2.pos_price as Ret_Dollars
into	#OV
from	reference.dbo.rtvtrn t1 left join reference.dbo.rtvtrnh t3
on		t3.debit_number = t1.debit_number
and		t3.scan_code <> 'C'
left join reference.dbo.void_items t2
on		t2.store = t1.store_number
and		t2.sku_number = t1.sku_number 
where	t1.return_date >= @sd
order by t1.store_number
--
insert into staging.dbo.wrk_Void1_Split
select	11 as grp,
		t1.store_number,
		t1.ret_Qty as OS_Qty,
		t1.sku_number,
		t1.Item_Type,
		t1.scan_ID,
		t1.Ret_Qty,
		t2.POS_Price,
		t1.Ret_Qty * t2.POS_Price as Ret_Dollars
from	#OV t1,
		reference.dbo.item_master t2
where	t2.sku_number = t1.sku_number
and		t1.grp is null
--
truncate table staging.dbo.wrk_Void3
insert into staging.dbo.wrk_Void3
select	t1.Store,
		t1.grp,
		t2.goal,
		t2.goal_dollars,
		sum(t1.ret_qty) as Ret_Qty,
		sum(t1.ret_dollars) as ret_dollars
from	staging.dbo.wrk_Void1_Split t1,
		reference.dbo.void_goals t2
where		t1.store = t2.store_number
and		t1.grp = t2.grp
group by t1.store,t1.grp,t2.goal,t2.goal_dollars
order by t1.store,t1.grp,t2.goal
--
update staging.dbo.wrk_Void2_Split
set	ret_Qty = staging.dbo.wrk_Void3.Ret_Qty,
Ret_Dollars = staging.dbo.wrk_Void3.Ret_Dollars
from staging.dbo.wrk_Void3
where staging.dbo.wrk_Void3.Store = staging.dbo.wrk_Void2_Split.Store_Number
and staging.dbo.wrk_Void3.Grp = staging.dbo.wrk_Void2_Split.Grp
GO
