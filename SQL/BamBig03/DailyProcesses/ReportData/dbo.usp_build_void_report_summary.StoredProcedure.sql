USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_void_report_summary]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[usp_build_void_report_summary]
as
Declare @sd smalldatetime
select @sd = max(Start_Date) from reference.dbo.void_items
--
truncate table staging.dbo.wrk_Void2
insert into staging.dbo.wrk_Void2
select distinct t1.store_number,
            t1.grp,
            t1.goal,
            t1.goal_dollars,
            0 as Ret_Qty,
            0 as Ret_Dollars
--into staging.dbo.wrk_Void2
from  reference.dbo.void_goals t1
order by t1.store_number,t1.grp
--
truncate table staging.dbo.wrk_void1
insert into staging.dbo.wrk_void1
select      t1.grp,
            t1.store,
            t1.OS_Qty,
            t1.sku_number,
            isnull(t3.Scan_ID,' ') as Scan_ID,
            isnull(t3.Store_Qty,0) as Ret_Qty,
            t1.pos_price,
            isnull(t3.store_qty,0) * t1.pos_price as Ret_Dollars
from  reference.dbo.void_items t1 left join
            reference.dbo.rtvtrn t3 
on          t3.store_number = t1.store
and         t3.sku_number = t1.sku_number
and   t3.return_date >= @sd
order by t1.store,t1.grp
--
select      t2.grp,
            t1.store_Number,
            t1.sku_number,
            t1.Scan_ID,
            t1.Store_Qty as Ret_Qty,
            t2.pos_price,
            t1.store_qty * t2.pos_price as Ret_Dollars
into  #OV
from  reference.dbo.rtvtrn t1 
left join reference.dbo.void_items t2
on          t2.store = t1.store_number
and         t2.sku_number = t1.sku_number 
where t1.return_date >= @sd
order by t1.store_number
--
insert into staging.dbo.wrk_void1
select      11 as grp,
            t1.store_number,
            t1.ret_Qty as OS_Qty,
            t1.sku_number,
            t1.scan_ID,
            t1.Ret_Qty,
            t2.POS_Price,
            t1.Ret_Qty * t2.POS_Price as Ret_Dollars
from  #OV t1,
            reference.dbo.item_master t2
where t2.sku_number = t1.sku_number
and         t1.grp is null
--
truncate table staging.dbo.wrk_Void3
insert into staging.dbo.wrk_Void3
select      t1.Store,
            t1.grp,
            t2.goal,
            t2.goal_dollars,
            sum(t1.ret_qty) as Ret_Qty,
            sum(t1.ret_dollars) as ret_dollars
from  staging.dbo.wrk_void1 t1,
            reference.dbo.void_goals t2
where       t1.store = t2.store_number
and         t1.grp = t2.grp
group by t1.store,t1.grp,t2.goal,t2.goal_dollars
order by t1.store,t1.grp,t2.goal
--
update staging.dbo.wrk_Void2
set   ret_Qty = staging.dbo.wrk_Void3.Ret_Qty,
Ret_Dollars = staging.dbo.wrk_Void3.Ret_Dollars
from staging.dbo.wrk_Void3
where staging.dbo.wrk_Void3.Store = staging.dbo.wrk_Void2.Store_Number
and staging.dbo.wrk_Void3.Grp = staging.dbo.wrk_Void2.Grp

--
truncate table reportdata.dbo.void_report_detail
insert into reportdata.dbo.void_report_detail
select      t1.grp,
            t1.store,
            t1.sku_number,
            t1.Item_Type,
            t2.Dept,
            t2.Dept_Name,
            t2.SDept,
            t2.SDept_Name,
            t2.Class,
            t2.Class_Name,
            t2.Author,
            t2.ISBN,
            t2.title,
            t1.OS_Qty,
            t1.OS_Qty * t2.POS_Price,
            0,
            0,
            0,
            0,
            0
from  reference.dbo.void_items t1,
            reference.dbo.item_master t2
where t2.sku_number = t1.sku_number
and         t1.Store > 104
--
insert into reportdata.dbo.void_report_detail
select      distinct t1.grp,
            t1.store,
            t1.sku_number,
            'V',
            t2.Dept,
            t2.Dept_Name,
            t2.SDept,
            t2.SDept_Name,
            t2.Class,
            t2.Class_Name,
            t2.Author,
            t2.ISBN,
            t2.title,
            sum(t1.OS_Qty),
            sum(t1.OS_Qty) * t2.POS_Price,
            sum(t1.ret_Qty),
            isnull(sum(t1.Ret_Dollars),0),
            0,
            0,
            0
from  staging.dbo.wrk_void1 t1,
            reference.dbo.item_master t2
where t2.sku_number = t1.sku_number
and         t1.grp = 11
and         t1.Store > 104
group by t1.grp,
            t1.store,
            t1.sku_number,
            t2.Dept,
            t2.Dept_Name,
            t2.SDept,
            t2.SDept_Name,
            t2.Class,
            t2.Class_Name,
            t2.Author,
            t2.ISBN,
            t2.title,
            t2.POS_Price

--
-- add item sales
--
select      t1.store_number,
            t1.sku_number,
            sum(t2.Item_Quantity) as SLSD
into  #Sales
from  reportdata.dbo.void_report_detail t1,
            dssdata.dbo.detail_transaction_history t2
where t2.store_number = t1.store_number
and         t2.sku_number = t1.sku_number
and         t2.day_date >= @sd
group by t1.store_number,t1.sku_number
--
select      t1.store_number,
            t1.sku_number,
            t2.POS_Price,
            sum(t1.Store_Qty) as Ret_Qty
into  #v1
from  reference.dbo.rtvtrn  t1,
            reference.dbo.item_master t2
where t1.return_date >= @sd
and         t2.sku_number = t1.sku_number
group by t1.store_number,t1.sku_number,t2.POS_Price
--
update      reportdata.dbo.void_report_detail
set         ret_qty = #v1.ret_Qty,
            ret_dollars = #v1.ret_qty * #V1.POS_Price
from  #v1
where reportdata.dbo.void_report_detail.store_number = #v1.store_number
and         reportdata.dbo.void_report_detail.sku_number = #v1.sku_number
--
update      reportdata.dbo.void_report_detail
set         Goal_Remaining = Goal - ret_Qty,
            Perc_Complete = ISNULL(ret_Qty / NULLIF(Goal, 0), 0)
--
update      reportdata.dbo.void_report_detail
set         Item_Sales = #Sales.SLSD
from  #Sales
where reportdata.dbo.void_report_detail.store_number = #Sales.store_number
and         reportdata.dbo.void_report_detail.sku_number = #Sales.sku_number
--
truncate table reportdata.dbo.void_report_summary
insert into reportdata.dbo.void_report_summary
select      store_Number,
            grp,
            sum(goal) as Goal,
            sum(Goal_Dollars) as Goal_Dollars,
            sum(Ret_Qty) as Ret_Qty,
            sum(Ret_dollars) as Ret_dollars,
            sum(Item_Sales) as Sales
from  reportdata.dbo.void_report_detail
group by store_number,grp
order by store_number,grp
--
truncate table reportdata.dbo.void_report_summary_split
insert into reportdata.dbo.void_report_summary_split
select      t1.store_Number,
            t2.Item_Type,
            t1.grp,
            sum(t1.goal) as Goal,
            sum(t1.Goal_Dollars) as Goal_Dollars,
            sum(t1.Ret_Qty) as Ret_Qty,
            sum(t1.Ret_dollars) as Ret_dollars,
            sum(t1.Item_Sales) as Item_Sales
from  reportdata.dbo.void_report_detail t1,
            reference.dbo.void_items t2
where t2.sku_number = t1.sku_number
and         t2.store = t1.store_Number
group by t1.store_number,t2.item_type,t1.grp
order by t1.store_number,t1.grp
GO
