USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_Pub_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Build_rpt_Pub_Report]
AS
BEGIN
	SET NOCOUNT ON;

	truncate table ReportData.dbo.rpt_Pub_Report

	insert into ReportData.dbo.rpt_Pub_Report
	SELECT     Publisher.PUBCode AS Pub, Publisher.Buyer, Publisher.PubName, SUM(Period_Sales.Week1Dollars) AS WK1TY, SUM(Period_Sales.lyWeek1Dollars) 
                      AS WK1LY, SUM(Period_Sales.Week2Dollars) AS WK2TY, SUM(Period_Sales.lyWeek2Dollars) AS WK2LY, SUM(Period_Sales.Week3Dollars) 
                      AS WK3TY, SUM(Period_Sales.lyWeek3Dollars) AS WK3LY, SUM(Period_Sales.Week4Dollars) AS WK4TY, SUM(Period_Sales.lyWeek4Dollars) 
                      AS WK4LY, SUM(Period_Sales.Week5Dollars) AS WK5TY, SUM(Period_Sales.lyWeek5Dollars) AS WK5LY, SUM(Period_Sales.TYYTDollars) 
                      AS TYYTD, SUM(Period_Sales.LYYTDollars) AS LYYTD, getdate() as Date_Created
	FROM		DssData.dbo.Period_Sales INNER JOIN
                      Reference.dbo.Item_Dim ON Period_Sales.ISBN = Reference.dbo.Item_Dim.d_and_w_item_number AND 
                      Period_Sales.SKU_Number = Reference.dbo.Item_Dim.sku_number INNER JOIN
                      Reference.dbo.Publisher ON Reference.dbo.Item_Dim.pub_code = Publisher.PUBCode
	GROUP BY Publisher.PUBCode, Publisher.Buyer, Publisher.PubName
	ORDER BY Publisher.Buyer, Publisher.PUBCode


END



GO
