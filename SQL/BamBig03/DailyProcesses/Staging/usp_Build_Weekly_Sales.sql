USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Weekly_Sales]    Script Date: 8/19/2022 3:32:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[usp_Build_Weekly_Sales]
as
declare @Sales_Week_End smalldatetime
declare @Sales_Week_Start smalldatetime
--
select @Sales_Week_End = staging.dbo.fn_Last_Saturday(getdate())
select @Sales_Week_Start = dateadd(dd,-6,@Sales_Week_End)
--
delete from dssdata.dbo.Weekly_Sales where day_date = @Sales_Week_End
--
if exists(select * from Staging.dbo.sysobjects where Name = 'tmp_Weekly_Sales' and  XType = 'U')
  drop table Staging.dbo.tmp_Weekly_Sales 
--
select cdt.store_number, 
	cdt.sku_number, 
	sum(cdt.item_quantity) as current_units,
	sum(cdt.extended_price) as current_dollars
into Staging.dbo.tmp_weekly_sales
from DssData.dbo.detail_transaction_history cdt
inner join Reference.dbo.item_master cid on cid.sku_number = cdt.sku_number 
where day_date between @Sales_Week_Start and @Sales_Week_End AND
	cdt.transaction_code IN ('01', '02', '03', '04', '11', '14', '22', '44','31', '53', '85', '86','ES','ED')
group by cdt.store_number,cdt.sku_number
order by cdt.store_number
--
insert into dssdata.dbo.weekly_sales
select	@Sales_Week_End as day_date,
		t1.Store_Number,
		t1.sku_number,
		t2.Store_Name,
		t5.ISBN,
		t5.title,
		t5.author,
		t5.pubcode,
		t1.current_units,
		t1.current_dollars,
		NULL as On_Hand,
		GetDate() as Load_Date
from	Staging.dbo.tmp_Weekly_Sales t1
		left join Reference.dbo.active_stores t2 on t2.store_number = t1.store_number
		left join Reference.dbo.item_master t5 on t5.sku_number = t1.sku_number
--		left join Reference.dbo.invbal t6 on t6.store_number = t1.store_number and t6.sku_number = t1.sku_number