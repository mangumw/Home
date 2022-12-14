USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_New_WhseOnHand]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_New_WhseOnHand]
as
IF  EXISTS (SELECT * FROM Staging.sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[dbo].[new_whseown]') AND type in (N'U'))
DROP TABLE [Staging].[dbo].[new_Whseown]

SELECT	reference.dbo.itmst.Class, 
		reference.dbo.itmst.RetailPrice, 
		reference.dbo.itbal.ISBN, 
		reference.dbo.itbal.WarehouseID, 
		reference.dbo.itbal.Base_OnHand AS whse_oh, 
		reference.dbo.itbal.Allocated AS cycle_t, 
		reference.dbo.itbal.OnBackOrder AS back_order, 
		reference.dbo.itbal.OnPO AS open_ord 
INTO	staging.dbo.new_whseown
FROM	reference.dbo.itbal INNER JOIN reference.dbo.itmst 
		ON reference.dbo.itbal.ISBN = reference.dbo.itmst.ISBN
WHERE (((reference.dbo.itbal.WarehouseID)='1') AND ((reference.dbo.itbal.OnHand)>0));
 
SELECT	staging.dbo.WhseOnHand.dept, 
		staging.dbo.WhseOnHand.category, 
		staging.dbo.WhseOnHand.WA_disct, 
		Sum([RetailPrice]*[whse_oh]) AS Retail_TTL, 
		Sum([RetailPrice]*[whse_oh])*(1-[WA_disct]) AS Cost_TTL
FROM	staging.dbo.new_whseown INNER JOIN staging.dbo.WhseOnHand 
		ON new_whseown.Class = staging.dbo.WhseOnHand.dept
GROUP BY staging.dbo.WhseOnHand.dept, 
		staging.dbo.WhseOnHand.category, staging.dbo.WhseOnHand.WA_disct
 


GO
