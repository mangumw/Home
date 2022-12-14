USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Card_2NC]    Script Date: 8/19/2022 3:15:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Build_Card_2NC]

AS
--	
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

declare @year int
declare @week int
declare @seldate smalldatetime


-- Pull item level information from invmst, item master, buyer tables, extended item master, and D&W balance file
truncate table Staging.dbo.wrk_Card_Descriptive_2NC
--
insert into Staging.dbo.wrk_Card_Descriptive_2NC
SELECT     Reference.dbo.INVMST.ISBN, Reference.dbo.INVMST.Sku_Number, Reference.dbo.Item_Master.EAN, NULL AS DW_ISBN, Reference.dbo.INVMST.Description AS Title, 
                      Reference.dbo.INVMST.Status, Reference.dbo.INVMST.Pub_Code, Reference.dbo.Item_Master.Publisher, Reference.dbo.INVMST.Vendor_Number AS VIN, 
                      Reference.dbo.INVMST.Author, Reference.dbo.Item_Master.Returnable, Reference.dbo.Item_Master.Disposition, Reference.dbo.Buyer_SrBuyer_XRef.Sr_Buyer, 
                      Reference.dbo.Buyer_SrBuyer_XRef.Buyer, Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number, Reference.dbo.INVMST.Dept, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.INVMST.SDept, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.INVMST.Class, 
                      Reference.dbo.Item_Master.Class_Name, Reference.dbo.INVMST.SClass, Reference.dbo.Item_Master.SClass_Name, Reference.dbo.INVMST.Module, 
                      Reference.dbo.INVMST.Sku_Type, Reference.dbo.INVMST.Subject, Reference.dbo.INVMST.Strength, Reference.dbo.INVMST.POS_Price AS Retail, 
                      Reference.dbo.ITBAL.DWCost, Reference.dbo.ITBAL.Min_Qty, Reference.dbo.ITBAL.Max_Qty, Reference.dbo.INVMST.Coordinate_Group, 
                      Reference.dbo.INVMST.Season, Reference.dbo.INVMST.Date_First_Activity AS IDate, dbo.fn_IntToDate(Reference.dbo.INVMSTE.ExpReceiptDate) AS ExpReceiptDate, 
                      Reference.dbo.INVMST.Condition, Reference.dbo.Item_Master.Sku_Text
FROM         Reference.dbo.INVMST INNER JOIN
                      Reference.dbo.Item_Master ON Reference.dbo.Item_Master.SKU_Number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.Buyer_SrBuyer_XRef ON Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number = Reference.dbo.INVMST.Buyer_Number INNER JOIN
                      Reference.dbo.INVMSTE ON Reference.dbo.INVMSTE.Sku_Number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.ITBAL ON Reference.dbo.ITBAL.Sku_Number = Reference.dbo.INVMST.Sku_Number
WHERE     (Reference.dbo.INVMST.Sku_Type <> 'M')


--Pull the on-hand information by SKU and store for 2NC items.  Store in reference.dbo.invbal_2NC
truncate table reference.dbo.invbal_2NC
Insert INTO reference.dbo.invbal_2NC

SELECT        sku_number, Store_Number, SUM(IBWKCR) AS [Current Week Sales], SUM(On_Hand) AS On_Hand, SUM(On_Order) AS On_Order, In_Transit, Wk1_SLSU, Wk2_SLSU, Wk3_SLSU, Wk4_SLSU, Wk5_SLSU, 
                         Wk6_SLSU, Wk7_SLSU, Wk8_SLSU
FROM            Reference.dbo.INVBAL
GROUP BY sku_number, Store_Number, In_Transit, Wk1_SLSU, Wk2_SLSU, Wk3_SLSU, Wk4_SLSU, Wk5_SLSU, Wk6_SLSU, Wk7_SLSU, Wk8_SLSU
HAVING        (Store_Number BETWEEN 2099 AND 2999)

-- Get life to date units ( Do we need this?)
truncate table staging.dbo.wrk_Card_LTD_2NC
insert into staging.dbo.wrk_Card_LTD_2NC
select	t1.sku_number,
		LifeTodateUnits as LTD_Units,
		LifeToDateDollars as LTD_Dollars
from	reference.dbo.item_master t1 
		left join reference.dbo.invcbl t2
		on t2.sku_number = t1.sku_number

-- Get last Saturday's date
select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)

--Get WTD Sales
truncate table staging.dbo.wrk_Card_WTD_2NC
insert into staging.dbo.wrk_Card_WTD_2NC
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as WTD_Units,
		isnull(sum(t2.Extended_Price),0) as WTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and (t2.store_number BETWEEN 2099 and 2999)
		and t2.day_date > @seldate
group by t1.sku_number


-- Get mins for 2NC 
Truncate table 	staging.dbo.display_min_2NC
insert into staging.dbo.display_min_2NC
--
SELECT        Sku_Number, SUM(Display_Min) AS display_min
FROM            Reference.dbo.Item_Display_Min
WHERE        (Store_Number BETWEEN 2099 AND 2999)
GROUP BY Sku_Number

--Get Summary of 2NC OH, In Transit, On Order by SKU
TRUNCATE table staging.dbo.wrk_Inv_OnHands_2NC
insert into staging.dbo.wrk_Inv_OnHands_2NC

SELECT        sku_number, SUM(On_Hand) AS On_Hand, SUM(On_Order) AS On_Order, SUM(In_Transit) AS In_Transit, SUM(Transfer_OO) AS Transfer_OO
FROM            Reference.dbo.INVBAL
WHERE        (Store_Number BETWEEN 2100 AND 2999)
GROUP BY sku_number


--Get Depot OH, OO and InTrans
TRUNCATE Table staging.dbo.wrk_Inv_Depot
Insert Into   staging.dbo.wrk_Inv_Depot
SELECT        sku_number, ISNULL(SUM(On_Hand), 0) AS On_Hand, ISNULL(SUM(In_Transit), 0) AS In_Transit, ISNULL(SUM(On_Order), 0) AS On_Order, SUM(Transfer_OO) AS Depot_Qty_OO
FROM            Reference.dbo.INVBAL
GROUP BY sku_number, Store_Number
HAVING        (Store_Number = 2001)

--Get ReturnCenter OnHands
truncate table staging.dbo.wrk_card_WMBAL_2NC
insert into staging.dbo.wrk_card_WMBAL_2NC
select	ISBN,
		isnull(sum(onhand),0) as OnHand
from	reference.dbo.WMBAL
where	left(location,1) in ('7','8','9')
and warehouse = 1
group by ISBN

--Build the inventory work file
TRUNCATE table Staging.dbo.wrk_Card_Inventory_2NC
insert into Staging.dbo.wrk_Card_Inventory_2NC
SELECT        Reference.dbo.Item_Master.SKU_Number, Reference.dbo.ITBAL.WarehouseID, ISNULL(wrk_Inv_OnHands_2NC.On_Hand, 0) AS On_Hand_2NC, ISNULL(wrk_Inv_OnHands_2NC.Transfer_OO, 0) 
                         + wrk_Inv_OnHands_2NC.In_Transit AS OnOrder_2NC, ISNULL(Reference.dbo.ITBAL.OnBackOrder, 0) AS Qty_OnBackorder, ISNULL(wrk_Inv_OnHands_2NC.In_Transit, 0) AS In_Transit, 
                         ISNULL(Reference.dbo.ITBAL.OnHand, 0) AS Warehouse_OnHand, ISNULL(display_min_2NC.display_min, 0) AS Display_Min
FROM            Reference.dbo.Item_Master LEFT OUTER JOIN
                         wrk_Inv_OnHands_2NC ON Reference.dbo.Item_Master.SKU_Number = wrk_Inv_OnHands_2NC.sku_number LEFT OUTER JOIN
                         Reference.dbo.INVCBL ON wrk_Inv_OnHands_2NC.sku_number = Reference.dbo.INVCBL.Sku_number LEFT OUTER JOIN
                         Reference.dbo.ITBAL ON wrk_Inv_OnHands_2NC.sku_number = Reference.dbo.ITBAL.Sku_Number LEFT OUTER JOIN
                         display_min_2NC ON wrk_Inv_OnHands_2NC.sku_number = display_min_2NC.Sku_Number
-- End of work table construction

-- Combine work tables into single table
TRUNCATE table Staging.dbo.tmp_CARD_New_2NC
insert into Staging.dbo.tmp_CARD_New_2NC

/*Move data to CARD Table							*/
SELECT        t1.ISBN, t1.Sku_Number AS SKU, t1.EAN, t1.DW_ISBN, t1.Title, t1.Status, t1.Pub_Code, t1.Publisher, t1.VIN, t1.Author, t1.Returnable, t1.Disposition, t1.Sr_Buyer, t1.Buyer, t1.Buyer_Number, t1.Dept, 
                         t1.Dept_Name, t1.SDept, t1.SDept_Name, t1.Class, t1.Class_Name, t1.SClass, t1.SClass_Name, t1.Module, t1.Sku_Type, t1.Subject, t1.Strength, 0 AS Bookscan_Rank, 0 AS Internet_Rank, NULL 
                         AS BAM_WOS, NULL AS AWBC_WOS, CASE WHEN t3.Week1Units > 0 AND t4.On_Hand_2NC > 0 THEN isnull(t3.Week1Units / nullif((t3.Week1Units + t4.On_Hand_2NC),0),0) ELSE 0 END AS Sell_Thru, t1.DWCost, t1.Retail, 
                         t1.Coordinate_Group, t1.Season, t1.IDate, t1.ExpReceiptDate, ISNULL(t8.IBCSQT, 0) AS Case_Qty, t4.OnOrder_2NC, t9.On_Order AS Depot_OnOrder, t4.On_Hand_2NC AS Onhand_2NC, t9.On_Hand AS Depot_OH, 
                         t4.Display_Min, t4.Warehouse_OnHand, wrk_card_WMBAL_2NC.OnHand AS ReturnCenter_OH, t9.Depot_Qty_OO, t4.Qty_OnBackorder, t9.In_Transit AS InTransit, t9.In_Transit AS Depot_InTransit, 
                         ISNULL(t3.WEEK1UNITS, 0) AS Week1Units, ISNULL(t3.WEEK1DOLLARS, 0) AS Week1Dollars, ISNULL(t3.WEEK2UNITS, 0) AS Week2Units, ISNULL(t3.WEEK2Dollars, 0) AS Week2dollars, 
                         ISNULL(t3.WEEK3UNITS, 0) AS week3units, ISNULL(t3.WEEK3Dollars, 0) AS week3dollars, ISNULL(t3.LYWEEK1UNITS, 0) AS lyweek1units, ISNULL(t3.LYWEEK1Dollars, 0) AS lyweek1dollars, 
                         ISNULL(t3.LYWEEK2UNITS, 0) AS lyweek2units, ISNULL(t3.LYWEEK2Dollars, 0) AS lyweek2dollars, ISNULL(t3.LYWEEK3UNITS, 0) AS lyweek3units, ISNULL(t3.LYWEEK3Dollars, 0) AS lyweek3dollars, 
                         ISNULL(t3.TYYTDUNITS, 0) AS TYYTDUnits, ISNULL(t3.TYYTDDOLLARS, 0) AS TYYTDDollars, ISNULL(t3.LYYTDUNITS, 0) AS LYYTDUnits, ISNULL(t3.LYYTDDOLLARS, 0) AS LYYTDDollars, 
                         ISNULL(t3.Week13Units, 0) AS Week13units, ISNULL(t3.Week13Dollars, 0) AS week13dollars, ISNULL(t5.WTD_Units, 0) AS wtd_units, ISNULL(t5.WTD_Dollars, 0) AS wtd_dollars, ISNULL(t6.LTD_Units, 0) 
                         AS ltd_units, ISNULL(t6.LTD_Dollars, 0) AS ltd_dollars, t1.Condition, t2.Qty_OnOrder

FROM            wrk_Card_Descriptive_2NC AS t1 INNER JOIN
                         Dssdata.dbo.CARD AS t2 ON t1.Sku_Number = t2.Sku_Number LEFT OUTER JOIN
                         wrk_card_WMBAL_2NC ON t1.ISBN = wrk_card_WMBAL_2NC.ISBN LEFT OUTER JOIN
                         wrk_Inv_Depot AS t9 ON t1.Sku_Number = t9.sku_number LEFT OUTER JOIN
                         Dssdata.dbo.Three_Week_Sales_2NC AS t3 ON t3.SKU_NUMBER = t1.Sku_Number LEFT OUTER JOIN
                         wrk_Card_Inventory_2NC AS t4 ON t4.SKU_Number = t1.Sku_Number LEFT OUTER JOIN
                         wrk_Card_WTD_2NC AS t5 ON t5.sku_number = t1.Sku_Number LEFT OUTER JOIN
                         wrk_Card_LTD_2NC AS t6 ON t6.Sku_Number = t1.Sku_Number LEFT OUTER JOIN
                         Reference.dbo.ITWHM AS t8 ON t8.IBITNO = t1.Sku_Text


TRUNCATE table dssdata.dbo.card_2NC
----
insert into dssdata.dbo.CARD_2NC

select distinct * from Staging.dbo.tmp_CARD_New_2NC
