USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Top_30_Missed_Items]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Top_30_Missed_Items]
as
declare @stores int
truncate table reportdata.dbo.void_report_detail_stores
declare cur cursor for select store_number from reference.dbo.active_stores
open cur
fetch next from cur into @stores
while @@fetch_status = 0
begin
	insert into reportdata.dbo.void_report_detail_stores
	select top 30 *  from reportdata.dbo.void_report_detail
	where store_number = @Stores and grp < 11 
	order by goal_remaining desc
fetch next from cur into @stores
end
close cur
deallocate cur
select t1.grp
      ,t1.store_number
	  ,t2.Region_Number
	  ,t2.Region_Name
	  ,t2.District_Number
	  ,t2.District_Name
      ,t1.sku_number
      ,t1.Item_Type
      ,t1.Dept
      ,t1.Dept_Name
      ,t1.SDept
      ,t1.SDept_Name
      ,t1.Class
      ,t1.Class_Name
      ,t1.Author
      ,t1.Scan_ID
      ,t1.Title
      ,t1.goal
      ,t1.goal_dollars
      ,t1.Ret_Qty
      ,t1.Ret_Dollars
      ,t1.Goal_Remaining
      ,t1.Perc_complete
      ,t1.Item_Sales
from reportdata.dbo.void_report_detail_stores t1,
     reference.dbo.Active_Stores t2
where t2.store_number = t1.store_number order by t1.store_number
GO
