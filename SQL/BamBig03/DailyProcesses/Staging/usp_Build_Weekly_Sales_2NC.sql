USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Weekly_Sales_2NC]    Script Date: 8/19/2022 3:36:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[usp_Build_Weekly_Sales_2NC]
as
declare @Sales_Week_End smalldatetime
declare @Sales_Week_Start smalldatetime
--
select @Sales_Week_End = staging.dbo.fn_Last_Saturday(getdate())
select @Sales_Week_Start = dateadd(dd,-6,@Sales_Week_End)
--
delete from dssdata.dbo.Weekly_Sales_2NC where day_date = @Sales_Week_End
--
if exists(select * from Staging.dbo.sysobjects where Name = 'tmp_Weekly_Sales_2NC' and  XType = 'U')
  drop table Staging.dbo.tmp_Weekly_Sales_2NC 
--
SELECT        cdt.Store_Number, cdt.Sku_Number, SUM(cdt.Item_Quantity) AS current_units, SUM(cdt.Extended_Price) AS current_dollars
into Staging.dbo.tmp_weekly_sales_2NC
FROM            Dssdata.dbo.Detail_Transaction_History AS cdt INNER JOIN
                         Reference.dbo.Item_Master AS cid ON cid.SKU_Number = cdt.Sku_Number
WHERE        (cdt.Day_Date BETWEEN @Sales_Week_Start AND @Sales_Week_End) AND (cdt.Transaction_Code IN ('01', '02', '03', '04', '11', '14', '22', '44', '31', '53', '85', '86', 'ES', 'ED'))
GROUP BY cdt.Store_Number, cdt.Sku_Number
HAVING        (cdt.Store_Number BETWEEN 2099 AND 2999)
ORDER BY cdt.Store_Number



insert into dssdata.dbo.weekly_sales_2NC
SELECT        @Sales_Week_End AS day_date, t1.Store_Number, t1.Sku_Number, t2.Store_name, t5.ISBN, t5.Title, t5.Author, t5.PubCode, t1.current_units, t1.current_dollars, NULL AS On_Hand, GETDATE() AS Load_Date
FROM            tmp_weekly_sales_2NC AS t1 LEFT OUTER JOIN
                         Reference.dbo.active_stores AS t2 ON t2.Store_number = t1.Store_Number LEFT OUTER JOIN
                         Reference.dbo.Item_Master AS t5 ON t5.SKU_Number = t1.Sku_Number
WHERE        (t1.Store_Number BETWEEN 2099 AND 2999)



