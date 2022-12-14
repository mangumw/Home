USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Internet_Weekly_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_Build_Internet_Weekly_Sales]
as

declare @Sales_Week_End smalldatetime
declare @Sales_Week_Start smalldatetime

select @Sales_Week_End = staging.dbo.fn_Last_Saturday(getdate())
select @Sales_Week_Start = dateadd(dd,-6,@Sales_Week_End)

delete from dssdata.dbo.Internet_Weekly_Sales where day_date = @Sales_Week_End


insert into Dssdata.dbo.Internet_Weekly_Sales
select	@Sales_Week_End as day_date,
		t1.ISBN as ISBN,
		t2.Sku_Number,
		t2.Title,
		t2.Author,
		t2.PubCode,
		sum(t1.Item_Quantity) as Current_Units,
		sum(t1.Extended_price) as Current_Dollars
from	dssdata.dbo.detail_transaction_period t1 inner join
		Reference.dbo.item_master t2
On		t2.sku_number = t1.sku_number
where	t1.day_date >= @Sales_Week_Start and t1.day_date <= @Sales_Week_End
and		t1.Store_Number = 55
group by t1.ISBN,
		t2.sku_number,
		t2.title,
		t2.author,
		t2.pubcode
--		
truncate table reference.dbo.internet_rank
--
insert into reference.dbo.internet_rank
select  Dense_Rank () OVER (order by Current_Units desc ) as Rank,
		isbn,
		Current_Units
from	dssdata.dbo.internet_weekly_sales
where	day_date = @Sales_Week_End
and		current_units > 0







GO
