USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Markdown_By_Item_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Markdown_By_Item_Report]
as
declare @Batch int
declare @Markdown_Qty int
declare @ISBN varchar(20)
declare @MD_Date smalldatetime
declare @store_Number int
declare @Validated tinyint
declare @Posted tinyint
declare @SD smalldatetime
--
select @SD = max(MD_Date) from reference.dbo.Markdown_Goals
--
select	t1.MD_Date,
		t1.ISBN,
		t2.sku_number,
		t2.Title,
		t2.SDept_Name,
		t2.BuyerName,
		Sum(t1.On_Hand) as Markdown_Goal,
		0 as Batch_Number,
        0 as Markdown_Qty,
		' ' as Validated,
		' ' as Posted
into	#Goals
from	reference.dbo.Markdown_Goals t1, 
		Reference.dbo.item_master t2,
		Reference.dbo.active_stores t3
where	t1.MD_Date >= @SD
and		t2.ISBN = t1.ISBN
and		t1.store_number = t3.store_number
group by t1.MD_Date,t1.ISBN,t2.sku_number,t2.title,t2.sdept_name,t2.buyername
--
CREATE NONCLUSTERED INDEX [#idx_goals] ON [#goals]
(
	[MD_Date] ASC,
	[ISBN] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF) ON [PRIMARY]

declare cur cursor for select MD_Date,ISBN from #Goals
open cur
fetch next from cur into @MD_Date,@ISBN
while @@Fetch_Status = 0
begin
select @Markdown_Qty = sum(Qty) 
from reference.dbo.markdown_log
where ItemKey = @ISBN and DateAdd >= @MD_Date

--
if @Markdown_Qty > 0
update #Goals set Markdown_Qty = @Markdown_Qty
where MD_Date = @MD_Date 
and ISBN = @ISBN
--
fetch next from cur into @MD_Date,@ISBN
end
close cur
deallocate cur

drop table ReportData.dbo.rpt_Markdown_By_Item_Report
select * into ReportData.dbo.rpt_Markdown_by_item_Report from #goals








select * from #goals
where isbn = '0061136840'

GO
