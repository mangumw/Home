USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Extract_RND_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Extract_RND_Data]
as
truncate table staging.dbo.RND_Sales
insert into staging.dbo.RND_Sales
select	t1.day_date,
		t2.pubcode as Pub,
		t1.Store_Number,
		t1.ISBN,
		t1.Sku_Number,
		t2.Title as item_name,
		t2.SDept as SubDepartment,
		t2.Class,
		t2.SClass as SubClass,
		t1.current_dollars,
		t1.current_units
from	dssdata.dbo.Weekly_Sales t1 inner join
		reference.dbo.item_master t2
on		t2.sku_number = t1.sku_number
where 	t1.pub_code = 'RND'
and		t1.day_date >= staging.dbo.fn_dateonly(dateadd(mm,-13,staging.dbo.fn_dateonly(getdate())))
--


		
		
		
	

		
		
		
		










GO
