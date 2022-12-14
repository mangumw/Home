USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Top_150_District_Summary_PY]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Top_150_District_Summary_PY]
@District int
as
declare @seldate smalldatetime
declare @enddate as smalldatetime
declare @Store int
select @enddate = staging.dbo.fn_Last_Saturday(getdate()-365)
select @seldate = dateadd(dd,-365,@enddate)
--
select  District_Number,store_number
into	#Stores
from	reference.dbo.active_stores
where	District_Number = @District

truncate table reportdata.dbo.Top_150_District_Summary_PY
----
insert into reportdata.dbo.Top_150_District_Summary_PY
select	Top 50
		@enddate as day_date,
		@District as District_Number,
		t1.isbn,
		t2.title,
		t2.author,
		t2.dept_name,
		t2.sdept_Name,
		sum(t1.Extended_Price) as Item_Sales,
		sum(t1.Item_Quantity) as Item_Qty
from	Dssdata.dbo.detail_transaction_history t1,
		reference.dbo.item_master t2,
		#Stores t3
where	t3.District_number = @District
and		t1.store_number = t3.Store_Number
and		t2.sku_number = t1.sku_number
and		t1.day_date >= @seldate and day_date <= @enddate
and                         t2.Dept NOT IN (16,87)
group by t3.District_Number,t1.isbn,t2.title,t2.author,t2.dept_name,t2.sdept_name
order by t3.District_Number,sum(t1.extended_price) desc
--
GO
