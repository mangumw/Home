USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_150_District_Prop_Detail]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_150_District_Prop_Detail]
@District int
as
declare @Store int
truncate table rpt_Top_150_District_Prop_Detail
declare cur cursor for select store_number from reference.dbo.active_stores where district_number = @District
open cur
fetch next from cur into @Store
while @@fetch_status = 0
begin
insert into rpt_Top_150_District_Prop_Detail
select top 100 *
from	reportdata.dbo.Prop_Sales 
where	Store_Number = @Store
order by TYYTD_SLSD Desc
fetch next from cur into @Store
end
close cur
deallocate cur
select * from rpt_Top_150_District_Prop_Detail
order by Store_Number,TYYTD_SLSD desc
GO
