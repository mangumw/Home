USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Void_Report_Group_Split]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Void_Report_Group_Split]
as
truncate table staging.dbo.wrk_Void2_split
insert into staging.dbo.wrk_Void2_Split
select	store,
		item_type,
		grp,
		sum(os_qty) as goal,
		sum(os_Qty * POS_Price) as Goal_dollars,
		0,
		0
from	reference.dbo.void_items
group by store,
		item_type,
		grp
order by store,item_type,grp
--
GO
