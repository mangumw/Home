USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Markdown_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Markdown_Report]
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
		t3.Region_Number,
		t3.District_Number,
		t1.Store_Number,
		t1.ISBN,
		t2.Title,
		t1.Current_retail,
		t1.New_retail,
		t1.On_Hand as Markdown_Goal,
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
and     t3.store_number = t1.Store_number
--
CREATE NONCLUSTERED INDEX [#idx_goals] ON [#goals]
(
	[MD_Date] ASC,
	[Store_Number] ASC,
	[ISBN] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF) ON [PRIMARY]

declare cur cursor for select MD_Date,Store_Number,ISBN from #Goals
open cur
fetch next from cur into @MD_Date,@Store_Number,@ISBN
while @@Fetch_Status = 0
begin
select @Markdown_Qty = Qty,@Batch = BatchNo,@Validated = Validated,@Posted=Posted 
from reference.dbo.markdown_log
where StoreNo = @Store_Number and ItemKey = @ISBN and DateAdd >= @MD_Date

--
if @Batch IS NOT NULL
update #Goals set Batch_Number = @Batch,Markdown_Qty = @Markdown_Qty,Validated=@Validated,Posted=@Posted
where MD_Date = @MD_Date 
and Store_Number = @Store_Number
and ISBN = @ISBN
--
fetch next from cur into @MD_Date,@Store_Number,@ISBN
end
close cur
deallocate cur

drop table ReportData.dbo.rpt_Markdown_Report
select * into ReportData.dbo.rpt_Markdown_Report from #goals




GO
