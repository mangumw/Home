USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Yesterday_Receipt]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Populate_Yesterday_Receipt]
as
TRUNCATE TABLE REPORTDATA.DBO.rpt_Yesterday_Receipts
insert into reportdata.dbo.Yesterday_Receipts
SELECT	Reference.dbo.Item_Master.ISBN, 
		Reference.dbo.Item_Master.BuyerName, 
		reference.dbo.Receipt_Tracking.PO AS PO, 
		reference.dbo.Receipt_Tracking.Unit_Cost AS Unit_Cost, 
		reference.dbo.Receipt_Tracking.Unit_Rtl AS Unit_Rtl, 
		Sum(reference.dbo.Receipt_Tracking.Rec_Qty) AS Rec_qty, 
		reference.dbo.Receipt_Tracking.Day_Date
FROM	Reference.dbo.Receipt_Tracking INNER JOIN Reference.dbo.Item_Master 
ON		reference.dbo.Receipt_Tracking.ISBN = Reference.dbo.Item_Master.ISBN
WHERE (((reference.dbo.Receipt_Tracking.Whse)='1'))
and		reference.dbo.Receipt_Tracking.day_date = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
GROUP BY Reference.dbo.Item_Master.ISBN, Reference.dbo.Item_Master.BuyerName, reference.dbo.Receipt_Tracking.PO, reference.dbo.Receipt_Tracking.Unit_Cost, reference.dbo.Receipt_Tracking.Unit_Rtl, reference.dbo.Receipt_Tracking.Day_Date;



GO
