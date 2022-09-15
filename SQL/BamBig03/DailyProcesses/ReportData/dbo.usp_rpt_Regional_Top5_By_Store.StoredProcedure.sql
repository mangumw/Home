USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Regional_Top5_By_Store]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_Regional_Top5_By_Store]
as
declare @store int
declare @sd smalldatetime
declare @ed smalldatetime
declare @qt varchar(7)
select @qt = staging.dbo.fn_LastQuarter(getdate())
select @sd = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @qt
select @ed = max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @qt

drop table reportdata.dbo.rpt_reg_top5
create table reportdata.dbo.rpt_reg_top5
(
Start_Date		smalldatetime,
End_Date		smalldatetime,
store_number	int,
store_name		varchar(50),
isbn			varchar(30),
item_name		varchar(50),
Dept			int,
SDept			int,
Class			int,
current_units	int,
current_dollars	money
)


declare scur cursor for select store_number from reference.dbo.store_dim
open scur
fetch next from scur into @store
while @@fetch_status = 0
begin
insert into reportdata.dbo.rpt_reg_top5
select	top 10
		@SD as Start_Date,
		@ED as End_Date,
		t1.store_number,
		t1.store_name,
		t1.isbn,
		t1.item_name,
		t2.dept,
		t2.sdept,
		t2.class,
		sum(t1.current_units) as SLSU,
		sum(t1.current_dollars) as SLSD
from	reference.dbo.item_master t2,
		dssdata.dbo.weekly_sales t1
where	t2.dept = 4
and		t2.sdept = 116
and		t2.class = 504
and		t1.sku_number = t2.sku_number
and		t1.day_date >= @sd and t1.day_date <= @ed
and		t1.store_number = @store
group by t1.isbn,t1.item_name,t1.store_number,t1.store_name,t2.dept,t2.sdept,t2.class
ORDER BY t1.store_number,sum(t1.current_units) desc
--
insert into reportdata.dbo.rpt_reg_top5
select	top 10
		@SD as Start_Date,
		@ED as End_Date,
		t1.store_number,
		t1.store_name,
		t1.isbn,
		t1.item_name,
		t2.dept,
		t2.sdept,
		t2.class,
		sum(t1.current_units) as SLSU,
		sum(t1.current_dollars) as SLSD
from	reference.dbo.item_master t2,
		dssdata.dbo.weekly_sales t1
where	t2.dept = 4
and		t2.sdept = 130
and		t2.class = 504
and		t1.sku_number = t2.sku_number
and		t1.day_date >= @sd and t1.day_date <= @ed
and		t1.store_number = @store
group by t1.isbn,t1.item_name,t1.store_number,t1.store_name,t2.dept,t2.sdept,t2.class
ORDER BY t1.store_number,sum(t1.current_units) desc

fetch next from scur into @store
end
close scur
deallocate scur

select * from reportdata.dbo.rpt_reg_top5






GO
