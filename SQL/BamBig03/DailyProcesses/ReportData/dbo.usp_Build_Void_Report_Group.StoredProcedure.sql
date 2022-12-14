USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Void_Report_Group]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Void_Report_Group]
as
truncate table staging.dbo.wrk_Void2
insert into staging.dbo.wrk_Void2
select distinct t1.store_number,
		t1.grp,
		t1.goal,
		t1.goal_dollars,
		0 as Ret_Qty,
		0 as Ret_Dollars 
from	reference.dbo.void_goals t1
order by t1.store_number,t1.grp

truncate table staging..wrk_void1
insert into staging..wrk_void1
select t1.grp,
		t1.store,
		t1.OS_Qty,
		t1.sku_number,
		t3.Scan_ID,
		t3.Store_Qty as Ret_Qty,
		t1.pos_price,
		t3.store_qty * t1.pos_price as Ret_Dollars
from	reference.dbo.void_items t1, 
		reference..void_goals t2,
		reference..rtvtrn t3
where   t3.store_number = t1.store
and		t2.store_number = t1.store
and		t2.grp = t1.grp
and		t3.sku_number = t1.sku_number
and 	t3.return_date >= '03-27-2009'

truncate table staging.dbo.wrk_Void3
insert into staging.dbo.wrk_Void3
select  t1.store,
		t1.grp,
		t2.goal,
		t2.goal_dollars,
		sum(t1.Ret_Qty) as ret_qty,
		sum(t1.Ret_Dollars) as ret_dollars
from staging.dbo.wrk_Void1 t1,
     reference.dbo.void_goals t2
where t1.store = t2.store_number
and t1.grp = t2.grp
group by t1.store,t1.grp, t2.goal,t2.goal_dollars
order by t1.store,t1.grp,t2.goal

update staging..wrk_void2
Set ret_qty = staging..wrk_void3.ret_qty,
ret_dollars = staging..wrk_void3.ret_dollars
from staging..wrk_void3
where staging..wrk_void3.store = staging..wrk_void2.store_number
and staging..wrk_void3.grp =   staging..wrk_void2.grp

truncate table reportdata..void_report_group
insert into reportdata..void_report_group
select grp,store_number,goal,goal_dollars,ret_qty,ret_dollars
from staging..wrk_void2
where store_number not in (197,219) order by grp,store_number


GO
