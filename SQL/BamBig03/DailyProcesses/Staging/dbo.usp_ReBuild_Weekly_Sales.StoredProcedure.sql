USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_ReBuild_Weekly_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE Procedure [dbo].[usp_ReBuild_Weekly_Sales]
 @Sales_Week_End smalldatetime
as
declare @Start smalldatetime
declare @Sales_Week_Start smalldatetime
declare @last_date smalldatetime

select @Sales_Week_Start =  dateadd(dd,-6,@sales_week_end)
select @sales_week_start,@sales_week_end,@Last_Date


delete from dssdata.dbo.Weekly_Sales where day_date = @Sales_Week_End

if exists(select * from Staging.dbo.sysobjects where Name = 'tmp_Weekly_Sales' and  XType = 'U')
  drop table Staging.dbo.tmp_Weekly_Sales 

select cdt.store_number, 
	cdt.sku_number, 
	sum(cdt.item_quantity) as current_units,
	sum(cdt.extended_price) as current_dollars
into Staging.dbo.tmp_weekly_sales
from dssdata.dbo.detail_transaction_history cdt
inner join Reference.dbo.item_dim cid on cid.sku_number = cdt.sku_number 
inner join Reference.dbo.store_dim csd on csd.store_number = cdt.store_number
where day_date between @Sales_Week_Start and @Sales_Week_End AND
	(csd.store_group_number = 29 OR cdt.store_number IN( '197','219','995','998'))AND
	csd.date_closed is null  AND
	cdt.transaction_code IN ('01', '02', '03', '04', '11', '14', '22', '44', '53','31','85', '86','ES','ED')

group by cdt.store_number,cdt.sku_number
order by cdt.store_number

insert into dssdata.dbo.weekly_sales
SELECT     @Sales_Week_End AS day_date, t1.store_number, t2.store_name, t1.sku_number, t5.d_and_w_item_number AS ISBN, t5.item_name, t5.author, t5.pub_code, 
                      t1.current_units, t1.current_dollars, NULL AS OnHand, GETDATE() AS Load_Date
FROM         tmp_weekly_sales AS t1 LEFT OUTER JOIN
                      Reference.dbo.Store_Dim AS t2 ON t2.store_number = t1.store_number LEFT OUTER JOIN
                      Reference.dbo.Item_Dim AS t5 ON t5.Sku_Number = t1.sku_number
WHERE     (t1.store_number <> 54)

GO
