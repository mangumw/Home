USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[USP_BUILD_DOT_COM_REPORT]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_BUILD_DOT_COM_REPORT]
AS 
DECLARE @sd smalldatetime
DECLARE @ed smalldatetime
DECLARE @ts money
SELECT @ed = staging.dbo.fn_last_saturday(getdate())
SELECT @sd = dateadd(dd,-6,@ed)

TRUNCATE TABLE staging.dbo.internet_selling
INSERT INTO staging.dbo.internet_selling
SELECT	t1.sku_number, 
		t1.store_number, 
		t1.day_date, 
		Sum(t1.Item_Quantity) AS SumOfCSQTY, 
		Sum(t1.Extended_price) AS SumOfCSEXPR, 0 
FROM	dssdata.dbo.detail_transaction_history t1
GROUP BY t1.sku_number, t1.store_number, t1.day_date
HAVING (((t1.store_number)>55) AND ((t1.day_date) Between @sd And @ed ));


TRUNCATE TABLE staging.dbo.internet_sell_thru
INSERT INTO staging.dbo.internet_sell_thru
SELECT  t2.day_date, 
		t3.Dept_Name, 
		t3.SDept_Name, 
		t3.Class_Name, 
        Sum(t2.SumOfCSQTY) AS TotOfCSQTY, 
		Sum(t2.SumOfCSEXPR) AS TotOfCSEXPR, 0
FROM	staging.dbo.internet_selling t2, 
		reference.dbo.Item_Master t3 
WHERE	t2.sku_number = t3.SKU_Number
GROUP BY t2.day_date,t3.Dept_Name, t3.SDept_Name,t3.Class_Name

SELECT @ts = Sum(extended_price)
FROM dssdata.dbo.detail_transaction_history
WHERE store_number > 55
AND ((day_date) Between @sd And @ed )
UPDATE staging.dbo.internet_selling
SET TotalSales = @ts

SELECT @ts = Sum(extended_price)
FROM dssdata.dbo.detail_transaction_history
WHERE store_number > 55
AND ((day_date) Between @sd And @ed )
UPDATE staging.dbo.internet_sell_thru
SET TotalSales = @ts
GO
