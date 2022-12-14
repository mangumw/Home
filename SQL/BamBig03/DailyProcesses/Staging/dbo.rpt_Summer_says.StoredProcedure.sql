USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Summer_says]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[rpt_Summer_says]
As

truncate table staging.dbo.wrk_Grant_OMT
insert into staging.dbo.wrk_Grant_OMT
SELECT     ft_craig.sku, CARD.ISBN, isnull(CARD.Sku_Number,0), CARD.Title, CARD.Author, CARD.Buyer, CARD.Dept, CARD.SDept_Name, CARD.Sku_Type, 
                      CARD.DWCost, CARD.Retail, CARD.Warehouse_OnHand, 
CARD.Qty_OnOrder,
SUM(Weekly_Sales.Current_Units) AS last_wk_u, 
                     SUM(Weekly_Sales.Current_Dollars) AS last_wk_dollar
FROM         staging.dbo.ft_craig AS ft_craig LEFT OUTER JOIN
                      DssData.dbo.CARD AS CARD ON CARD.Sku_Number = ft_craig.sku LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales AS Weekly_Sales ON CARD.sku_number = Weekly_Sales.Sku_Number and Weekly_sales.day_date = staging.dbo.fn_Last_Saturday(dateadd(dd,-7,GETDATE())) FULL OUTER JOIN
                      staging.dbo.summer_says_stores AS Summer_Says_Stores ON Weekly_Sales.Store_Number = Summer_Says_Stores.Store
GROUP BY ft_craig.sku, CARD.ISBN, CARD.Sku_Number, CARD.Title, CARD.Author, CARD.Buyer, CARD.Dept, CARD.SDept_Name, CARD.Sku_Type, 
                      CARD.DWCost, CARD.Retail, CARD.Warehouse_OnHand, CARD.Qty_OnOrder

truncate table staging.dbo.wrk_Grant_OMT_Inv
insert into staging.dbo.wrk_Grant_OMT_Inv
select      ft_craig.sku,
            sum(INVBAL.On_Hand) as BAM_OnHand
from  staging.dbo.ft_craig ft_craig,
            staging.dbo.summer_says_stores summer_says_stores,
            reference.dbo.INVBAL INVBAL
where INVBAL.Store_Number = summer_says_stores.Store
and         INVBAL.Sku_Number = ft_craig.Sku
group by ft_craig.sku

truncate table staging.dbo.wrk_Grant_OMTb
insert into staging.dbo.wrk_Grant_OMTb
SELECT  omt.sku, 
            omt.ISBN, 
            omt.Title, 
            omt.Author, 
            omt.Buyer, 
            omt.Dept, 
            omt.SDept_Name, 
            omt.Sku_Type, 
            omt.DWCost, 
            omt.Retail, 
            inv.BAM_OnHand, 
            omt.Warehouse_OnHand, 
            omt.Qty_OnOrder, 
            isnull(omt.last_wk_u,0) as last_wk_u,
        isnull(omt.last_wk_dollar,0) as last_wk_dollar,
           case
              when omt.last_wk_U > 0 and omt.last_wk_u + inv.BAM_OnHand > 0 then          
                      CAST(omt.last_wk_u AS Float) / (CAST(omt.last_wk_u AS float) + CAST(inv.BAM_OnHand AS Float)) 
            else 0 
                  END AS sell_thru, 
            case
                        when inv.BAM_OnHand > 0 and omt.last_wk_u > 0 then inv.BAM_OnHand / omt.last_wk_u 
                else 0
                  END AS WOS

FROM        staging.dbo.wrk_Grant_OMT omt left join
                  staging.dbo.wrk_Grant_Omt_Inv inv
on          omt.sku = inv.sku
GO
