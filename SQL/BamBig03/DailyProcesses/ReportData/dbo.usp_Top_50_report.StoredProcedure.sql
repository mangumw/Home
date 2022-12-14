USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Top_50_report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Top_50_report]
	@store_number int,
	@begin_date datetime,
	@end_Date datetime
as
declare @store_total_dollars money
declare @store_total_units int
truncate table reportdata.dbo.rpt_Store_Top_50
--
insert into reportdata.dbo.rpt_Store_Top_50
select	top 50 
		dth.Store_Number,
		dth.isbn, 
		i.title as item_name, 
		i.author, 
		i.Dept,
		i.Dept_Name, 
		i.SDept, 
		i.SDept_Name as subdepartment_short_name,
		sum(dth.extended_price) as total_dollars, 
		sum(dth.item_quantity) as total_units,
		cast(0.0000 as money) as store_total_dollars, 
		0 as store_total_units
 from	dssdata.dbo.detail_transaction_history dth 
		inner join reference.dbo.item_master i on dth.sku_number = i.sku_number
 where	dth.day_date between @begin_date and @end_date 
 and	dth.store_number = @store_number and dth.isbn is not null
 and	dth.transaction_code in ('01','04','02','85','11','14','22','86') and i.dept in (1,4,8)
 group by dth.Store_Number,dth.isbn, i.title, i.author, i.Dept, i.Dept_Name, i.sdept, i.SDept_name
 order by sum(dth.extended_price) desc

 select @store_total_dollars = sum(dth.extended_price), 
		@store_total_units = sum(dth.item_quantity)
 from	dssdata.dbo.detail_transaction_history dth 
		inner join reference.dbo.item_master i on dth.sku_number = i.sku_number
 where	dth.day_date between @begin_date and @end_date and dth.store_number = @store_number and dth.isbn is not null
 and	dth.transaction_code in ('01','04','02','85','11','14','22','86')

update reportdata.dbo.rpt_Store_Top_50 set store_total_dollars = @store_total_dollars, store_total_units = @store_total_units

select * from reportdata.dbo.rpt_Store_Top_50









GO
