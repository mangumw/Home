USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[topsellers_for_buyer]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[topsellers_for_buyer]
	@buyer_code char(3)

AS

SELECT	sku_number, 
	item_name, 
	isbn, 
	sku_type, 
--	sku_status, 
	store_number, 
--	day_date, 
--	department, 
--	subdepartment, 
--	class, 
	route_no, 			--***
	delivery_day, 		--***
	buyer_code, 
	on_hand, 
	on_order, 
	dollar_sales, 
	unit_sales, 
	prior_week_unit_sales, 
	awbc_avail, 
	stock_to, 
	sug_stock_level, 
	sug_order_level, 
	CASE WHEN expedited_ship <> 'Y' THEN '' ELSE 'Y' END AS expedited_ship
FROM Xmas_Replen_TopSellers
WHERE buyer_code = @buyer_code AND
      --department in (1,4,5,8, 6,12,13,16,58) AND
      sug_order_level > 1 AND
      sku_type <> 'B' --AND
      --day_date = DATEADD(d, -1, CAST(CAST(YEAR(GETDATE()) as varchar)+'-'+CAST(MONTH(GETDATE()) as varchar)+'-'+CAST(DAY(GETDATE()) as varchar) AS datetime))
ORDER BY isbn, store_number


GO
