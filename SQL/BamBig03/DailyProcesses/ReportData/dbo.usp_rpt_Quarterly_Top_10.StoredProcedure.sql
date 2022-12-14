USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Quarterly_Top_10]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_Quarterly_Top_10]
as
declare @fiscal_year int
declare @fiscal_quarter int
declare @sd smalldatetime
declare @ed smalldatetime
declare @last_quarter varchar(8)
select @fiscal_year = fiscal_year,@fiscal_quarter = cast(right(fiscal_quarter,1) as int) from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(getdate())
--
select @last_quarter = cast(@fiscal_year as char(4)) + '-Q' + cast(@fiscal_quarter - 1 as char(1))
if @fiscal_quarter = 1 
begin
  select @fiscal_year = @fiscal_year - 1
  select @last_quarter = cast(@fiscal_year as char(4)) + '-Q' + '4'
  end
--
select @sd = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_quarter = @last_quarter
select @ed = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_quarter = @last_quarter

declare @store	int
--
IF  EXISTS (SELECT * FROM ReportData.sys.objects WHERE object_id = OBJECT_ID(N'[ReportData].[dbo].[Quarterly_Top10]') AND type in (N'U'))
DROP TABLE [ReportData].[dbo].[Quarterly_Top10]
--
IF  EXISTS (SELECT * FROM Staging.sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[dbo].[Quarterly_Top10_Status]') AND type in (N'U'))
DROP TABLE [Staging].[dbo].[Quarterly_Top10_Status]
--
create table reportdata.dbo.Quarterly_Top10
(
Quarter			varchar(10),
Rank			bigint,
SDept			int,
Store_Number	int,
sku_number		int,
Title			varchar(30),
Price			Money,
Units			int
)
Create Table Staging.dbo.Quarterly_Top10_Status
(
day_date	smalldatetime,
Msg			varchar(50)
)

--
declare storecur cursor for select Store_Number from reference.dbo.store_dim
where Date_Closed is NULL order by store_number
--
open storecur
fetch next from storecur into @store

while @@Fetch_Status = 0
begin
--
insert into Reportdata.dbo.Quarterly_top10
select	top 10
		@Last_Quarter,
		Row_Number () OVER (order by sum(t1.current_units)desc) as RANK,
		t2.SDept,
		t1.store_number,
		t1.sku_number,
		t2.title,
		sum(t1.current_dollars),
		sum(t1.current_units)
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	t1.sku_number = t2.sku_number
and		t1.store_number = @store
and		t2.Dept = 4
and		t2.SDept = 116
and		t2.class = 504
and		t1.day_date >= @SD
and		t1.day_date <= @ED
group by t2.SDEpt,
		t1.store_number,
		t1.sku_number,
		t2.title
order by sum(t1.current_units) desc
--
insert into Reportdata.dbo.Quarterly_top10
select	top 10
		@Last_Quarter,
		Row_Number () OVER (order by sum(t1.current_units)desc) as RANK,
		t2.SDept,
		t1.store_number,
		t1.sku_number,
		t2.title,
		sum(t1.current_dollars),
		sum(t1.current_units)
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	t1.sku_number = t2.sku_number
and		t1.store_number = @store
and		t2.Dept = 4
and		t2.SDept = 130
and		t2.class = 504
and		t1.day_date >= @SD
and		t1.day_date <= @ED
group by t2.SDEpt,
		t1.store_number,
		t1.sku_number,
		t2.title
order by sum(t1.current_units) desc
insert into staging.dbo.Quarterly_Top10_Status  values (getdate(), 'Completed ' + cast(@store as char(4)))
fetch next from storecur into @store
end
--
close storecur
deallocate storecur
--







GO
