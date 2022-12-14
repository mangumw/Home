USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_Replen_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[Build_Replen_Data]
as





drop table replen_data

SELECT     DssData.dbo.CARD.Pub_Code, DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Title, DssData.dbo.CARD.Author, DssData.dbo.CARD.Buyer, DssData.dbo.CARD.Dept, 
                      DssData.dbo.CARD.SDept_Name, DssData.dbo.CARD.Class_Name, DssData.dbo.CARD.Store_Min, DssData.dbo.CARD.IDate, DssData.dbo.CARD.Sku_Type, 
                      DssData.dbo.CARD.Retail, DssData.dbo.CARD.BAM_OnHand, DssData.dbo.CARD.InTransit, Reference.dbo.ITBAL.OnBackOrder, 
                      DssData.dbo.CARD.ReturnCenter_OnHand, DssData.dbo.CARD.Warehouse_OnHand, DssData.dbo.CARD.Qty_OnOrder, DssData.dbo.CARD.Case_Qty, 
                      DssData.dbo.CARD.Week1Units, DssData.dbo.CARD.Week2Units, DssData.dbo.CARD.Week3Units, DssData.dbo.CARD.Week13Units, Reference.dbo.ITBAL.Max_Qty, 
                      ISNULL(Staging.dbo.caseflg.Y_or_N, N'N') AS case_flgY_N, 
                      DssData.dbo.CARD.Warehouse_OnHand + DssData.dbo.CARD.Qty_OnOrder - reference.dbo.itbal.onbackorder AS Available, 
                      CASE WHEN (DssData.dbo.CARD.Warehouse_OnHand + DssData.dbo.CARD.Qty_OnOrder - reference.dbo.itbal.onBackorder) 
                      > reference.dbo.itbal.Max_Qty THEN 0 ELSE reference.dbo.itbal.Max_Qty - (DssData.dbo.CARD.Warehouse_OnHand + DssData.dbo.CARD.Qty_OnOrder - reference.dbo.itbal.OnBackorder)
                       END AS Net_Need
into replen_data
FROM         Staging.dbo.caseflg RIGHT OUTER JOIN
                      DssData.dbo.CARD INNER JOIN
                      Reference.dbo.ITBAL ON DssData.dbo.CARD.Sku_Number = Reference.dbo.ITBAL.Sku_Number ON 
                      Staging.dbo.caseflg.Pub_Code = DssData.dbo.CARD.Pub_Code
WHERE     (NOT (DssData.dbo.CARD.Pub_Code IN ('1ox','avs','ech','lgc','2ox', 'arc', 'awbc', 'b$1', 'b$2', 'b$h', 'b&m', 'cbl', 'cff', 'dpp', 'taj', 'wpo', 'wpu', 'wr1', 'cmg', 'mle', 'img', 'hyg', 'phe', 
                      'phn', 'ede', 'htl', 'arc', 'taj', 'mcl', 'hyg', 'csm', 'pon', 'frp', 'mbk', 'atl', 'sqo', 'qdb'))) AND (DssData.dbo.CARD.BAM_OnHand > 0) AND 
                      (DssData.dbo.CARD.Sku_Type IN ('T', 'N', 'R')) AND (DssData.dbo.CARD.Dept IN (1, 4, 8)) AND 
                      (CASE WHEN (DssData.dbo.CARD.Warehouse_OnHand + DssData.dbo.CARD.Qty_OnOrder - reference.dbo.itbal.OnBackorder) 
                      > reference.dbo.itbal.Max_Qty THEN 0 ELSE reference.dbo.itbal.Max_Qty - (DssData.dbo.CARD.Warehouse_OnHand + DssData.dbo.CARD.Qty_OnOrder - reference.dbo.itbal.OnBackorder)
                       END > 0)











GO
