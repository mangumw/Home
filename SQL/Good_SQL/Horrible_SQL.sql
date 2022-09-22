USE [Dssdata]
GO

/****** Object:  View [dbo].[vw_VendorScoreCard]    Script Date: 9/22/2022 4:11:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_VendorScoreCard] as

with cte_VSC (Pub_Group, Purchases_TY, Purchases_LY, [Purchases % Inc/Dec], NetTY, NetLY, [Returns % Inc/Dec], [Return %], RefundsTY, RefundsLY,
Sales_TY, Sales_LY, [Sales % Inc/Dec], CoOp_TY, CoOp_LY, [CoOp % Inc/Dec], Inv_TY, Inv_LY, [Inv % Inc/Dec], Date_Loaded)
as
 (
 SELECT dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Pub_Code as Pub_Group,
 dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_TY, 
 dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_LY, 
 IIf(dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_LY = 0, 0, (dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_TY - dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_LY) / dssdata.dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_LY) AS [Purchases % Inc/Dec], 
 dbo.Publisher_Scorecard_YTD_PubGrp.Returns_TY, 
 dbo.Publisher_Scorecard_YTD_PubGrp.Returns_LY, 
 IIf([Returns_LY]=0,0,([Returns_TY]-[Returns_LY])/[Returns_LY]) AS [Returns % Inc/Dec], 
 IIf([Purchases_TY]=0,0,[Returns_TY]/[Purchases_TY]) AS [Return %],
 [Purchases_TY]-[Returns_TY] AS NetTY, /*I*/
 [Purchases_LY]-[Returns_LY] AS NetLY, /*J*/
 --IIf([RefundsLY]=0,0,([RefundsTY]-[RefundsLY])/[RefundsLY]) AS K, 
 dbo.Publisher_Scorecard_YTD_PubGrp.Sales_TY, 
 dbo.Publisher_Scorecard_YTD_PubGrp.Sales_LY, 
 IIf([Sales_LY]=0,0,([Sales_TY]-[Sales_LY])/[Sales_LY]) AS [Sales % Inc/Dec], 
 dbo.Publisher_Scorecard_YTD_PubGrp.CoOp_TY, 
 dbo.Publisher_Scorecard_YTD_PubGrp.CoOp_LY, 
 IIf([CoOp_LY]=0,0,([CoOp_TY]-[CoOp_LY])/[CoOp_LY]) AS [CoOp % Inc/Dec], 
 dbo.Publisher_Scorecard_YTD_PubGrp.Inv_TY, 
 dbo.Publisher_Scorecard_YTD_PubGrp.Inv_LY ,
 IIf([Inv_LY]=0,0,([Inv_TY]-[Inv_LY])/[Inv_LY]) AS [Inv % Inc/Dec], Date_Loaded
FROM dbo.Publisher_Scorecard_YTD_PubGrp
WHERE (((dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_TY)>0)) OR 
(((dbo.Publisher_Scorecard_YTD_PubGrp.Purchases_LY)>0)) OR 
(((dbo.Publisher_Scorecard_YTD_PubGrp.Returns_TY)>0)) OR 
(((dbo.Publisher_Scorecard_YTD_PubGrp.Returns_LY)>0))

)

Select Pub_Group, Purchases_TY, Purchases_LY, [Purchases % Inc/Dec], NetTY, NetLY, [Returns % Inc/Dec], [Return %], RefundsTY, RefundsLY,
IIf(NetLY=0,0,(NetTY-NetLY)/NetLY) AS [Net % Inc/Dec],
Sales_TY, Sales_LY, [Sales % Inc/Dec], CoOp_TY, CoOp_LY, [CoOp % Inc/Dec], Inv_TY, Inv_LY, [Inv % Inc/Dec], Date_Loaded
from cte_VSC
--order by Pub_Group

/*PLAY VISIONS                
PLAYMAKER TOYS                
*/
GO


