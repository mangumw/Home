USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_DSR_Store_Daily]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_DSR_Store_Daily]
as
--
declare @stores_missing int
declare	@yesterday as smalldatetime
set		@yesterday = staging.dbo.fn_dateonly(dateadd(dd,-7,getdate()))

--
delete	from dssdata.dbo.DSR_Store_Daily
where	day_date >= @yesterday
--
truncate table tmp_load.dbo.DSR_Detail
insert into tmp_load.dbo.DSR_Detail
select	day_date,
		store_number,
		dept,
		sum(extended_price) as Detail_Price,
		sum(Extended_Discount) as Discount
from	dssdata.dbo.detail_transaction_history
where	day_date >= @yesterday
and		store_number > 55
and		transaction_code <> 'VS'
group by day_date,store_number,dept
--
insert into tmp_load.dbo.DSR_Detail
select	day_date,
		store_number,
		dept,
		sum(extended_price),
		sum(Extended_Discount) as Discount
from	dssdata.dbo.other_transaction_history
where	day_date >= @yesterday
and		store_number > 55
and		transaction_code Not In ('44', '45','DO', '81', '82', '83', 'FP', '41', '39')
and		Dept is not null
group by day_date,store_number,dept
----
---- Gift Card Sales
----
insert into tmp_load.dbo.DSR_Detail
select	day_date,
		store_number,
		'GS' as Dept,
		sum(extended_price),
		sum(Extended_Discount) as Discount
from	dssdata.dbo.other_transaction_history
where	day_date >= @yesterday
and		store_number > 55
and		Transaction_Code = '45'
group by day_date,store_number
--
----
---- Gift Card Redemptions
----
insert into tmp_load.dbo.DSR_Detail
select	day_date,
		store_number,
		'GR' as Dept,
		sum(Tender_Amount),
		0 as Discount
from	dssdata.dbo.Tender_Transaction
where	day_date >= @yesterday
and		store_number > 55
and		Tender_Type in ('EG','GC')
group by day_date,store_number
--
insert into tmp_load.dbo.DSR_Detail
select	t1.day_date,
		t1.store_number,
		t2.dept,
		sum(t1.extended_price),
		sum(t1.Extended_Discount) as Discount
from	dssdata.dbo.other_transaction_history t1,
		reference.dbo.DSR_Special_Dept t2
where	t1.day_date >= @yesterday
and		t1.store_number > 55
and		t1.transaction_code = t2.dept
and		t2.Include = 1
group by t1.day_date,t1.store_number,t2.dept
--
insert into dssdata.dbo.dsr_store_daily
select	t1.day_date,
        t1.store_number,
        t1.dept,
		sum(t1.Detail_Price) as Extended_Price,
		sum(Discount) as Discount
from	tmp_load.dbo.DSR_Detail t1 
group by day_date,store_number,dept
order by t1.day_date,t1.store_number,t1.dept
--
-- Build Estimates for Missing Stores Comp
--
select @yesterday = staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate()))
select @stores_missing = 0
--
select	distinct store_number,sum(extended_price) as SLSD
into	#polled
from	dssdata.dbo.detail_transaction_period
where	day_date = @yesterday
group by store_number
--
select	store_number
into	#NotPolled
from	reference.dbo.Comp_stores
where	store_number in (select store_number from #polled where SLSD < 500)
--
select  @stores_missing = count(store_number) from #NotPolled
--
if @Stores_Missing > 0
begin
insert into dssdata.dbo.dsr_store_daily
select	@yesterday,
        t1.store_number,
        '4',
		sum(t2.Extended_price) as Extended_Price,
		sum(t2.extended_Discount) as Discount
from	#NotPolled t1 ,
		dssdata.dbo.detail_transaction_history t2
where	t2.day_date = staging.dbo.fn_Today_LY(@yesterday)
and		t2.store_number = t1.store_number
group by t1.store_number
end
truncate table reportdata.dbo.reporting_stores
insert into reportdata.dbo.reporting_stores
select  'C',
		@Stores_Missing

select	@stores_missing = count(store_number)
from	reference.dbo.Active_stores
where	store_number in (select store_number from #polled where SLSD < 500)
--
insert into reportdata.dbo.reporting_stores
select 'N',
		@Stores_missing


--drop table #polled
--drop table #notpolled
GO
