USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Daily_Top_20]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Missy Norris>
-- Create date: <5-1-14>
-- Description:	<Top 10>
-- =============================================
CREATE PROCEDURE [dbo].[Daily_Top_20]


AS
BEGIN

truncate table tmp_load.dbo.daily20
INSERT INTO  tmp_load.dbo.daily20
SELECT     t1.ISBN, rank() over (order by dssdata.dbo.card.dept)as ranking, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, DssData.dbo.CARD.Pub_Code, DssData.dbo.CARD.Publisher, DssData.dbo.CARD.Author, 
                      DssData.dbo.CARD.Dept, SUM(t1.Item_Quantity) AS Qty, SUM(t1.Extended_Price) AS Total

FROM         DssData.dbo.Detail_Transaction_History AS t1 INNER JOIN
                      DssData.dbo.CARD ON t1.Sku_Number = DssData.dbo.CARD.Sku_Number
WHERE     (t1.Store_Number <> 55) AND (NOT (DssData.dbo.CARD.Sku_Type IN ('VS', 'M')))
GROUP BY t1.Day_Date, t1.ISBN, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, DssData.dbo.CARD.Pub_Code, DssData.dbo.CARD.Publisher, 
                      DssData.dbo.CARD.Author, DssData.dbo.CARD.Dept
HAVING      (t1.Day_Date = Staging.dbo.fn_DateOnly(DATEADD(dd, - 1, GETDATE()))) AND (DssData.dbo.CARD.Dept IN (1, 4, 8))
ORDER BY Total DESC

END
GO
