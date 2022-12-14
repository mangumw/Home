USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Daily_Item_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Populate_Daily_Item_Sales]
as
--
declare @Mindate smalldatetime
declare @Maxdate smalldatetime
--
select @mindate = min(day_date) from dssdata.dbo.detail_transaction_period
select @maxdate = max(day_date) from dssdata.dbo.detail_transaction_period
--
delete from dssdata.dbo.daily_item_sales where day_date >= @mindate and day_date <= @maxdate
--
insert into dssdata.dbo.daily_item_sales
select	day_date,
		sku_number,
		sum(item_quantity) as Daily_Units,
		sum(Extended_Price) as Daily_Dollars,
		staging.dbo.fn_dateonly(getdate()) as Load_Date
from	dssdata.dbo.detail_transaction_period
where sku_number IS NOT NULL
group by day_date,sku_number
order by day_date,sku_number
		
GO
