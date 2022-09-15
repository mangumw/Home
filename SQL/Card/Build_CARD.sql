USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_CARD]    Script Date: 9/13/2022 3:45:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[usp_Build_CARD]

as

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

--	
declare @year int
declare @week int
declare @seldate smalldatetime

select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)

--select @seldate
--
truncate table Staging.dbo.wrk_Card_Descriptive
--

insert into Staging.dbo.wrk_Card_Descriptive
(      [ISBN]
      ,[Sku_Number]
      ,[EAN]
      ,[DW_ISBN]
      ,[Title]
      ,[Status]
      ,[Pub_Code]
      ,[Publisher]
      ,[VIN]
      ,[Author]
      ,[Returnable]
      ,[Disposition]
      ,[Sr_Buyer]
      ,[Buyer]
      ,[Buyer_Number]
      ,[Dept]
      ,[Dept_Name]
      ,[SDept]
      ,[SDept_Name]
      ,[Class]
      ,[Class_Name]
      ,[SClass]
      ,[SClass_Name]
      ,[Module]
      ,[Sku_Type]
      ,[Subject]
      ,[Strength]
      ,[Retail]
      ,[DWCost]
      ,[Min_Qty]
      ,[Max_Qty]
      ,[Coordinate_Group]
      ,[Season]
      ,[IDate]
      ,[ExpReceiptDate]
      ,[Condition]
      ,[Sku_Text]
)
SELECT     [Reference].[dbo].INVMST.ISBN, [Reference].[dbo].INVMST.Sku_Number, [Reference].[dbo].Item_Master.EAN, NULL AS DW_ISBN, [Reference].[dbo].INVMST.Description AS Title, 
                      [Reference].[dbo].INVMST.Status, [Reference].[dbo].INVMST.Pub_Code, [Reference].[dbo].Item_Master.Publisher, [Reference].[dbo].INVMST.Vendor_Number AS VIN, 
                      [Reference].[dbo].INVMST.Author, [Reference].[dbo].Item_Master.Returnable, [Reference].[dbo].Item_Master.Disposition, [Reference].[dbo].Buyer_SrBuyer_XRef.Sr_Buyer, 
                      [Reference].[dbo].Buyer_SrBuyer_XRef.Buyer, [Reference].[dbo].Buyer_SrBuyer_XRef.Buyer_Number, [Reference].[dbo].INVMST.Dept, 
                      [Reference].[dbo].Item_Master.Dept_Name, [Reference].[dbo].INVMST.SDept, [Reference].[dbo].Item_Master.SDept_Name, [Reference].[dbo].INVMST.Class, 
                      [Reference].[dbo].Item_Master.Class_Name, [Reference].[dbo].INVMST.SClass, [Reference].[dbo].Item_Master.SClass_Name, [Reference].[dbo].INVMST.Module, 
                      [Reference].[dbo].INVMST.Sku_Type, [Reference].[dbo].INVMST.Subject, [Reference].[dbo].INVMST.Strength, [Reference].[dbo].INVMST.POS_Price AS Retail, 
                      [Reference].[dbo].ITBAL.DWCost, [Reference].[dbo].ITBAL.Min_Qty, [Reference].[dbo].ITBAL.Max_Qty, [Reference].[dbo].INVMST.Coordinate_Group, 
                      [Reference].[dbo].INVMST.Season, [Reference].[dbo].INVMST.Date_First_Activity AS IDate, dbo.fn_IntToDate([Reference].[dbo].INVMSTE.ExpReceiptDate) AS ExpReceiptDate, 
                      [Reference].[dbo].INVMST.Condition, [Reference].[dbo].Item_Master.Sku_Text
FROM         [Reference].[dbo].INVMST INNER JOIN
                      [Reference].[dbo].Item_Master ON [Reference].[dbo].Item_Master.SKU_Number = [Reference].[dbo].INVMST.Sku_Number LEFT OUTER JOIN
                      [Reference].[dbo].Buyer_SrBuyer_XRef ON [Reference].[dbo].Buyer_SrBuyer_XRef.Buyer_Number = [Reference].[dbo].INVMST.Buyer_Number INNER JOIN
                      [Reference].[dbo].INVMSTE ON [Reference].[dbo].INVMSTE.Sku_Number = [Reference].[dbo].INVMST.Sku_Number LEFT OUTER JOIN
                      [Reference].[dbo].ITBAL ON [Reference].[dbo].ITBAL.Sku_Number = [Reference].[dbo].INVMST.Sku_Number
WHERE     ([Reference].[dbo].INVMST.Sku_Type <> 'M')
--select @year = fiscal_year from [Reference].[dbo].calendar_dim where day_date = staging.dbo.fn_dateonly(getdate())
--select @week = max(weeknumber) from [Reference].[dbo].bookscan where yearnumber = @year
--truncate table staging.dbo.wrk_card_rank
--insert into staging.dbo.wrk_card_rank
--select	distinct t1.sku_number,
--		isnull(t2.rank,0) as Bookscan_Rank,
--		isnull(t3.rank,0) as Internet_Rank
--from	[Reference].[dbo].item_master t1
--		left join [Reference].[dbo].bookscan t2
--		on t2.isbn = t1.isbn
--		and t2.yearnumber = @year and weeknumber = @week
--		left join [Reference].[dbo].internet_rank t3
--		on t3.isbn = t1.isbn
--
truncate table staging.dbo.wrk_Card_DCLTD
insert into staging.dbo.wrk_Card_DCLTD
(	   [sku_number]
      ,[DCLTD_Units]
      ,[DCLTD_Dollars]
)
select	t1.sku_number,
		ISNULL(sum(t2.current_Units),0) as DCLTD_Units,
		ISNULL(sum(t2.Current_Dollars),0.00) as DCLTD_Dollars
from	[Reference].[dbo].item_master t1 
		left join dssdata.dbo.internet_weekly_sales t2
		on t2.sku_number = t1.sku_number
where t1.sku_number is not null
--AND t2.current_Units != 0
--AND t2.Current_Dollars != 0.00
group by t1.sku_number
--
truncate table staging.dbo.wrk_Card_LTD

insert into staging.dbo.wrk_Card_LTD
(	  
	   [sku_number]
      ,[LTD_Units]
      ,[LTD_Dollars]
)
select	t1.sku_number,
		LifeTodateUnits as LTD_Units,
		LifeToDateDollars as LTD_Dollars
from	[Reference].[dbo].item_master t1 
		left join [Reference].[dbo].invcbl t2
		on t2.sku_number = t1.sku_number


truncate table staging.dbo.wrk_Card_WTD
insert into
 staging.dbo.wrk_Card_WTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as WTD_Units,
		isnull(sum(t2.Extended_Price),0) as WTD_Dollars
from	[Reference].[dbo].item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and ((t2.Store_Number BETWEEN 100 AND 980)
		or (t2.store_number BETWEEN 2099 and 2999))
		and t2.day_date > @seldate
group by t1.sku_number

--

truncate table staging.dbo.wrk_Card_DCWTD
insert into staging.dbo.wrk_Card_DCWTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as DCWTD_Units,
		isnull(sum(t2.Extended_Price),0) as DCWTD_Dollars
from	[Reference].[dbo].item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and t2.store_number = 55
		and t2.day_date > @seldate
group by t1.sku_number

--
truncate table Staging.dbo.wrk_Card_Inventory
--
select	sku_number,
		sum(display_min) as display_min
into	#display_min
from	[Reference].[dbo].item_display_min
group by sku_number


--
-- Create On-Hands from invbal
--
-- Create On-Hands from invbal
--
truncate table staging.dbo.wrk_inv_onhands_All
insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	[Reference].[dbo].invcbl
group by sku_number

insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	staging.dbo.wrk_inv_onhands_dtl
group by sku_number

truncate table staging.dbo.wrk_Inv_onhands
insert into staging.dbo.wrk_Inv_OnHands
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	staging.dbo.wrk_inv_onhands_All
group by sku_number



--
-- Get ReturnCenter OnHands
--
truncate table staging.dbo.wrk_card_WMBAL
insert into staging.dbo.wrk_card_WMBAL
SELECT        ISBN, ISNULL(SUM(OnHand), 0) AS OnHand
FROM            [Reference].[dbo].WMBAL
WHERE        (LEFT(Location, 1) IN ('7', '8', '9')) AND (Warehouse = '1')
GROUP BY ISBN


insert into Staging.dbo.wrk_Card_Inventory
select	[Reference].[dbo].item_master.sku_number,
		[Reference].[dbo].ITBAL.WarehouseID,
		isnull(#display_min.Display_Min,0) as Store_Min,
		isnull(staging.dbo.wrk_inv_onhands.on_hand,0) as BAM_OnHand,
		Isnull([Reference].[dbo].INVCBL.TrfOnOrder,0) as BAM_OnOrder,
		isnull([Reference].[dbo].ITBAL.OnHand,0) AS Warehouse_OnHand, 
		isnull([Reference].[dbo].ITBAL.OnPO,0) AS Qty_OnOrder, 
		isnull([Reference].[dbo].ITBAL.OnBackOrder,0) AS Qty_OnBackorder, 
		isnull([Reference].[dbo].ITBAL.InTransit,0) as InTransit,
		isnull(staging.dbo.wrk_card_wmbal.OnHand,0) as ReturnCenter_OnHand,
		case
			when (staging.dbo.wrk_inv_onhands.On_Hand + isnull([Reference].[dbo].ITBAL.OnHand,0)) < 0
			then 0
		else
			isnull(staging.dbo.wrk_inv_onhands.On_Hand,0) + isnull([Reference].[dbo].ITBAL.OnHand,0) 
		End AS Total_OnHand
from	[Reference].[dbo].item_master 
		left join [Reference].[dbo].invcbl
		on [Reference].[dbo].invcbl.sku_number = [Reference].[dbo].item_master.sku_number
		left join [Reference].[dbo].itbal
		on [Reference].[dbo].itbal.sku_number = [Reference].[dbo].item_master.sku_number
		left join #display_min
		on #display_min.sku_number = [Reference].[dbo].item_master.sku_number
		left join staging.dbo.wrk_inv_onhands
		on staging.dbo.wrk_inv_onhands.sku_number = [Reference].[dbo].item_master.sku_number
		left join staging.dbo.wrk_card_wmbal on staging.dbo.wrk_card_wmbal.ISBN = [Reference].[dbo].item_master.sku_text
--
update Staging.dbo.wrk_Card_Inventory
set Store_Min = (select isnull(sum(Display_Min),0) from [Reference].[dbo].item_display_min
				where [Reference].[dbo].item_display_min.sku_number = Staging.dbo.wrk_Card_Inventory.sku_number)
where Store_Min = 0
--
-- End of work table construction
--
-- Combine work tables into single table
--
truncate table Staging.dbo.tmp_CARD_New
--
--
insert into Staging.dbo.tmp_CARD_new
SELECT     t1.ISBN, t1.Sku_Number AS SKU, t1.EAN, t1.DW_ISBN, t1.Title, t1.Status, t1.Pub_Code, t1.Publisher, t1.VIN, t1.Author, t1.Returnable, t1.Disposition, t1.Sr_Buyer, 
                      t1.Buyer, t1.Buyer_Number, t1.Dept, t1.Dept_Name, t1.SDept, t1.SDept_Name, t1.Class, t1.Class_Name, t1.SClass, t1.SClass_Name, t1.Module, t1.Sku_Type, 
                      t1.Subject, t1.Strength, 0 AS Bookscan_Rank, 0 AS Internet_Rank, NULL AS BAM_WOS, NULL AS AWBC_WOS, CASE WHEN t3.Week1Units > 0 AND 
                      t4.BAM_OnHand > 0 AND t3.Week1Units > 0 THEN isnull(t3.Week1Units / nullif((t3.Week1Units + t4.BAM_OnHand),0),0) ELSE 0 END AS Sell_Thru, t1.DWCost, t1.Retail, 
                      t1.Coordinate_Group, t1.Season, t1.IDate, t1.ExpReceiptDate, t4.Store_Min, t1.Min_Qty, t1.Max_Qty, ISNULL(t8.IBCSQT, 0) AS Expr1, t4.BAM_OnHand, 
                      t4.BAM_OnOrder, t4.Warehouse_OnHand, t4.ReturnCenter_OnHand, t4.Qty_OnOrder, t4.Qty_OnBackorder, t4.InTransit, t4.Total_OnHand, NULL AS NumStocked, 
                      ISNULL(t3.WEEK1UNITS, 0) AS Week1Units, ISNULL(t3.WEEK1DOLLARS, 0) AS Week1Dollars, ISNULL(t3.WEEK2UNITS, 0) AS Week2Units, ISNULL(t3.WEEK2Dollars, 
                      0) AS Week2dollars, ISNULL(t3.WEEK3UNITS, 0) AS week3units, ISNULL(t3.WEEK3Dollars, 0) AS week3dollars, ISNULL(t3.DCWeek1Units, 0) AS dcweek1units, 
                      ISNULL(t3.DCWeek1Dollars, 0) AS dcweek1dollars, ISNULL(t3.DCWeek2Units, 0) AS dcweek2units, ISNULL(t3.DCWeek2Dollars, 0) AS dcweek2dollars, 
                      ISNULL(t3.DCWeek3Units, 0) AS dcweek3units, ISNULL(t3.DCWeek3Dollars, 0) AS dcweek3dollars, ISNULL(t3.LYWEEK1UNITS, 0) AS lyweek1units, 
                      ISNULL(t3.LYWEEK1Dollars, 0) AS lyweek1dollars, ISNULL(t3.LYWEEK2UNITS, 0) AS lyweek2units, ISNULL(t3.LYWEEK2Dollars, 0) AS lyweek2dollars, 
                      ISNULL(t3.LYWEEK3UNITS, 0) AS lyweek3units, ISNULL(t3.LYWEEK3Dollars, 0) AS lyweek3dollars, ISNULL(t3.LYDCWeek1Units, 0) AS lydcweek1units, 
                      ISNULL(t3.LYDCWeek1Dollars, 0) AS lydcweek1dollars, ISNULL(t3.LYDCWeek2Units, 0) AS lydcweek2units, ISNULL(t3.LYDCWeek2Dollars, 0) AS lydcweek2dollars, 
                      ISNULL(t3.LYDCWeek3Units, 0) AS lydcweek3units, ISNULL(t3.LYDCWeek3Dollars, 0) AS lydcweek3dollars, ISNULL(t3.TYYTDUNITS, 0) AS TYYTDUnits, 
                      ISNULL(t3.TYYTDDOLLARS, 0) AS TYYTDDollars, ISNULL(t3.LYYTDUNITS, 0) AS LYYTDUnits, ISNULL(t3.LYYTDDOLLARS, 0) AS LYYTDDollars, 
                      ISNULL(t3.DCTYYTDUNITS, 0) AS DCTYYTDUnits, ISNULL(t3.DCTYYTDDOLLARS, 0) AS DCTYYTDDollars, ISNULL(t3.DCLYYTDUNITS, 0) AS DCLYYTDUnits, 
                      ISNULL(t3.DCLYYTDDOLLARS, 0) AS DCLYYTDDollars, ISNULL(t3.Week13Units, 0) AS Week13units, ISNULL(t3.Week13Dollars, 0) AS week13dollars, 
                      ISNULL(t3.DCWeek13Units, 0) AS dcweek13units, ISNULL(t3.DCWeek13Dollars, 0) AS dcweek13dollars, ISNULL(t5.WTD_Units, 0) AS wtd_units, 
                      ISNULL(t5.WTD_Dollars, 0) AS wtd_dollars, ISNULL(t9.DCWTD_Units, 0) AS DCwtd_units, ISNULL(t9.DCWTD_Dollars, 0) AS DCwtd_dollars, ISNULL(t6.LTD_Units, 0) 
                      AS ltd_units, ISNULL(t6.LTD_Dollars, 0) AS ltd_dollars, ISNULL(t7.DCLTD_Units, 0) AS dcltd_units, ISNULL(t7.DCLTD_Dollars, 0) AS dcltd_dollars, t4.Warehouse_ID, 
                      '' AS Expr2, '' AS Expr3, GETDATE() AS Load_Date, t1.Condition
FROM         wrk_Card_Descriptive AS t1 LEFT OUTER JOIN
                      DssData.dbo.Three_Week_Sales AS t3 ON t3.SKU_NUMBER = t1.Sku_Number LEFT OUTER JOIN
                      wrk_Card_Inventory AS t4 ON t4.sku_number = t1.Sku_Number LEFT OUTER JOIN
                      wrk_Card_WTD AS t5 ON t5.sku_number = t1.Sku_Number LEFT OUTER JOIN
                      wrk_card_ltd AS t6 ON t6.sku_number = t1.Sku_Number LEFT OUTER JOIN
                      wrk_Card_DCLTD AS t7 ON t7.sku_number = t1.Sku_Number LEFT OUTER JOIN
                      [Reference].[dbo].ITWHM AS t8 ON t8.IBITNO = t1.Sku_Text LEFT OUTER JOIN
                      wrk_Card_DCWTD AS t9 ON t9.sku_number = t1.Sku_Number
--
--update staging.dbo.tmp_card
--set store_min = (select sum(Display_Min) from [Reference].[dbo].Item_Display_Min
--where [Reference].[dbo].Item_Display_Min.sku_number = staging.dbo.tmp_card.sku_number)
--where staging.dbo.tmp_card.dept NOT IN (1,4,8)
--

truncate table [dssdata].[dbo].CARD
----
insert into [dssdata].[dbo].CARD
(
	   [ISBN]
      ,[Sku_Number]
      ,[EAN]
      ,[DW_ISBN]
      ,[Title]
      ,[Status]
      ,[Pub_Code]
      ,[Publisher]
      ,[VIN]
      ,[Author]
      ,[Returnable]
      ,[Disposition]
      ,[Sr_Buyer]
      ,[Buyer]
      ,[Buyer_Number]
      ,[Dept]
      ,[Dept_Name]
      ,[SDept]
      ,[SDept_Name]
      ,[Class]
      ,[Class_Name]
      ,[SClass]
      ,[SClass_Name]
      ,[Module]
      ,[Sku_Type]
      ,[Subject]
      ,[Strength]
      ,[Bookscan_Rank]
      ,[Internet_Rank]
      ,[BAM_WOS]
      ,[AWBC_WOS]
      ,[Sell_Thru]
      ,[DWCost]
      ,[Retail]
      ,[Coordinate_Group]
      ,[Season]
      ,[IDate]
      ,[ExpReceiptDate]
      ,[Store_Min]
      ,[Min_Qty]
      ,[Max_Qty]
      ,[Case_Qty]
      ,[BAM_OnHand]
      ,[BAM_OnOrder]
      ,[Warehouse_OnHand]
      ,[ReturnCenter_OnHand]
      ,[Qty_OnOrder]
      ,[Qty_OnBackorder]
      ,[InTransit]
      ,[Total_OnHand]
      ,[Stocked_Stores]
      ,[Week1Units]
      ,[Week1Dollars]
      ,[Week2Units]
      ,[Week2Dollars]
      ,[Week3Units]
      ,[Week3Dollars]
      ,[DCWeek1Units]
      ,[DCWeek1Dollars]
      ,[DCWeek2Units]
      ,[DCWeek2Dollars]
      ,[DCWeek3Units]
      ,[DCWeek3Dollars]
      ,[lyWeek1Units]
      ,[lyWeek1Dollars]
      ,[lyWeek2Units]
      ,[lyWeek2Dollars]
      ,[lyWeek3Units]
      ,[lyWeek3Dollars]
      ,[lyDCWeek1Units]
      ,[lyDCWeek1Dollars]
      ,[lyDCWeek2Units]
      ,[lyDCWeek2Dollars]
      ,[lyDCWeek3Units]
      ,[lyDCWeek3Dollars]
      ,[TYYTDUnits]
      ,[TYYTDDollars]
      ,[LYYTDUnits]
      ,[LYYTDDollars]
      ,[DCTYYTDUnits]
      ,[DCTYYTDDollars]
      ,[DCLYYTDUnits]
      ,[DCLYYTDDollars]
      ,[Week13Units]
      ,[Week13Dollars]
      ,[DCWeek13Units]
      ,[DCWeek13Dollars]
      ,[WTD_Units]
      ,[WTD_Dollars]
      ,[DCWTD_Units]
      ,[DCWTD_Dollars]
      ,[LTD_Units]
      ,[LTD_Dollars]
      ,[DCLTD_Units]
      ,[DCLTD_Dollars]
      ,[WarehouseID]
      ,[BowkerStatus]
      ,[IATRB3]
      ,[Load_Date]
      ,[Condition]
)

select distinct 
       [ISBN]
      ,[Sku_Number]
      ,[EAN]
      ,[DW_ISBN]
      ,[Title]
      ,[Status]
      ,[Pub_Code]
      ,[Publisher]
      ,[VIN]
      ,[Author]
      ,[Returnable]
      ,[Disposition]
      ,[Sr_Buyer]
      ,[Buyer]
      ,[Buyer_Number]
      ,[Dept]
      ,[Dept_Name]
      ,[SDept]
      ,[SDept_Name]
      ,[Class]
      ,[Class_Name]
      ,[SClass]
      ,[SClass_Name]
      ,[Module]
      ,[Sku_Type]
      ,[Subject]
      ,[Strength]
      ,[Bookscan_Rank]
      ,[Internet_Rank]
      ,[BAM_WOS]
      ,[AWBC_WOS]
      ,[Sell_Thru]
      ,[DWCost]
      ,[Retail]
      ,[Coordinate_Group]
      ,[Season]
      ,[IDate]
      ,[ExpReceiptDate]
      ,[Store_Min]
      ,[Min_Qty]
      ,[Max_Qty]
      ,[Case_Qty]
      ,[BAM_OnHand]
      ,[BAM_OnOrder]
      ,[Warehouse_OnHand]
      ,[ReturnCenter_OnHand]
      ,[Qty_OnOrder]
      ,[Qty_OnBackorder]
      ,[InTransit]
      ,[Total_OnHand]
      ,[Stocked_Stores]
      ,[Week1Units]
      ,[Week1Dollars]
      ,[Week2Units]
      ,[Week2Dollars]
      ,[Week3Units]
      ,[Week3Dollars]
      ,[DCWeek1Units]
      ,[DCWeek1Dollars]
      ,[DCWeek2Units]
      ,[DCWeek2Dollars]
      ,[DCWeek3Units]
      ,[DCWeek3Dollars]
      ,[lyWeek1Units]
      ,[lyWeek1Dollars]
      ,[lyWeek2Units]
      ,[lyWeek2Dollars]
      ,[lyWeek3Units]
      ,[lyWeek3Dollars]
      ,[lyDCWeek1Units]
      ,[lyDCWeek1Dollars]
      ,[lyDCWeek2Units]
      ,[lyDCWeek2Dollars]
      ,[lyDCWeek3Units]
      ,[lyDCWeek3Dollars]
      ,[TYYTDUnits]
      ,[TYYTDDollars]
      ,[LYYTDUnits]
      ,[LYYTDDollars]
      ,[DCTYYTDUnits]
      ,[DCTYYTDDollars]
      ,[DCLYYTDUnits]
      ,[DCLYYTDDollars]
      ,[Week13Units]
      ,[Week13Dollars]
      ,[DCWeek13Units]
      ,[DCWeek13Dollars]
      ,[WTD_Units]
      ,[WTD_Dollars]
      ,[DCWTD_Units]
      ,[DCWTD_Dollars]
      ,[LTD_Units]
      ,[LTD_Dollars]
      ,[DCLTD_Units]
      ,[DCLTD_Dollars]
      ,[WarehouseID]
      ,[BowkerStatus]
      ,[IATRB3]
      ,[Load_Date]
      ,[Condition] 
FROM [staging].[dbo].tmp_card_new


UPDATE dssdata..card 
SET bowkerstatus = B.status
FROM dssdata..card A INNER JOIN dssdata..bowker_biblio B ON A.isbn = B.isbn10 and a.bowkerstatus = ''

UPDATE dssdata..card 
SET bowkerstatus = B.status
FROM dssdata..card A INNER JOIN dssdata..bowker_biblio B ON A.isbn = B.isbn13 and a.bowkerstatus = ''

UPDATE dssdata..card 
SET bowkerstatus = B.status
FROM dssdata..card A INNER JOIN dssdata..bowker_biblio B ON A.isbn = B.ean and a.bowkerstatus = ''

UPDATE dssdata..card 
SET bowkerstatus = B.MMSstatus
FROM dssdata..card A INNER 
JOIN dssdata..Bowker_MMS_Status_Xref B 
ON A.bowkerstatus = B.bowkerstatus