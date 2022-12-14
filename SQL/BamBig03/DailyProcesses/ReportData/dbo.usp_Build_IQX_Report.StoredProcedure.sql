USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_IQX_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Build_IQX_Report]
as
--
-- Build I Report
--
drop table rpt_I_Report
--
SELECT  *
into	rpt_I_Report
FROM    DssData.dbo.CARD
WHERE   (DssData.dbo.CARD.Sku_Type = 'I') 
AND		(DssData.dbo.CARD.Strength <> '02') 
AND		(DssData.dbo.CARD.BAM_OnHand <> 0) 
OR		(DssData.dbo.CARD.Sku_Type = 'I') 
AND		(DssData.dbo.CARD.Strength <> '02') 
AND		(DssData.dbo.CARD.Warehouse_OnHand <> 0)
--
-- Build Q Report 
--
drop table rpt_Q_Report
--
SELECT  *
into	rpt_Q_Report
FROM    DssData.dbo.CARD
WHERE   (DssData.dbo.CARD.Sku_Type = 'Q') 
AND		(DssData.dbo.CARD.Strength <> '02') 
AND		(DssData.dbo.CARD.Warehouse_OnHand > 0)
--
-- Build X Report
--
drop table rpt_X_Report
--
SELECT  *
into	rpt_X_Report
FROM    DssData.dbo.CARD
WHERE   (Sku_Type = 'X') 
AND		(Strength <> '02') 
AND		(Warehouse_OnHand > 0)
--
-- Build BO Report
--
drop table rpt_BO_Report
--
SELECT  * 
into	rpt_BO_Report
FROM    DssData.dbo.CARD
WHERE	Dept In (1,4,8,6,14,16,3,58,69) 
AND		Qty_OnBackorder>10
--
-- END
--

GO
