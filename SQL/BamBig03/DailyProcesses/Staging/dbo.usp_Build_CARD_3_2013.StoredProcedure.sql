USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_CARD_3_2013]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set ANSI_NULLS ON
--set QUOTED_IDENTIFIER ON
--GO
--
---------------------------------------------------------------------------
---- Procedure: usp_Build_CARD
----
---- This proc will build the CARD (Consolidatede As400 Reporting Data) Table
---- from the Following tables:	INVMST
----								INVCBL
----								ITBAL	
----								Weekly_Sales
----
---- The CARD table is essentially the AS400 - 999 Report.
----
---------------------------------------------------------------------------------
----
CREATE procedure [dbo].[usp_Build_CARD_3_2013]
as

--	
declare @year int
declare @week int
declare @seldate smalldatetime


--
truncate table Staging.dbo.wrk_Card_Descriptive
--
insert into Staging.dbo.wrk_Card_Descriptive
SELECT     Reference.dbo.INVMST.ISBN, Reference.dbo.INVMST.Sku_Number, Reference.dbo.Item_Master.EAN, NULL AS DW_ISBN, 
                      Reference.dbo.INVMST.Description AS Title, Reference.dbo.INVMST.Status, Reference.dbo.INVMST.Pub_Code, Reference.dbo.Item_Master.Publisher, 
                      Reference.dbo.INVMST.Vendor_Number AS VIN, Reference.dbo.INVMST.Author, Reference.dbo.Item_Master.Returnable, 
                      Reference.dbo.Item_Master.Disposition, Reference.dbo.Buyer_SrBuyer_XRef.Sr_Buyer, Reference.dbo.Buyer_SrBuyer_XRef.Buyer, 
                      Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number, Reference.dbo.INVMST.Dept, Reference.dbo.Item_Master.Dept_Name, 
                      Reference.dbo.INVMST.SDept, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.INVMST.Class, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.INVMST.SClass, Reference.dbo.Item_Master.SClass_Name, Reference.dbo.INVMST.Module, Reference.dbo.INVMST.Sku_Type, 
                      Reference.dbo.INVMST.Subject, Reference.dbo.INVMST.Strength, Reference.dbo.INVMST.POS_Price AS Retail, Reference.dbo.ITBAL.DWCost, 
                      Reference.dbo.ITBAL.Min_Qty, Reference.dbo.ITBAL.Max_Qty, Reference.dbo.INVMST.Coordinate_Group, Reference.dbo.INVMST.Season, 
                      Reference.dbo.INVMST.Date_First_Activity AS IDate, dbo.fn_IntToDate(Reference.dbo.INVMSTE.ExpReceiptDate) AS ExpReceiptDate
FROM         Reference.dbo.INVMST INNER JOIN
                      Reference.dbo.Item_Master ON Reference.dbo.Item_Master.SKU_Number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.Buyer_SrBuyer_XRef ON Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number = Reference.dbo.INVMST.Buyer_Number INNER JOIN
                      Reference.dbo.INVMSTE ON Reference.dbo.INVMSTE.sku_number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.ITBAL ON Reference.dbo.ITBAL.Sku_Number = Reference.dbo.INVMST.Sku_Number
WHERE     (Reference.dbo.INVMST.Sku_Type <> 'M')
--select @year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(getdate())
--select @week = max(weeknumber) from reference.dbo.bookscan where yearnumber = @year
--truncate table staging.dbo.wrk_card_rank
--insert into staging.dbo.wrk_card_rank
--select	distinct t1.sku_number,
--		isnull(t2.rank,0) as Bookscan_Rank,
--		isnull(t3.rank,0) as Internet_Rank
--from	reference.dbo.item_master t1
--		left join reference.dbo.bookscan t2
--		on t2.isbn = t1.isbn
--		and t2.yearnumber = @year and weeknumber = @week
--		left join reference.dbo.internet_rank t3
--		on t3.isbn = t1.isbn
--
truncate table staging.dbo.wrk_Card_DCLTD
insert into staging.dbo.wrk_Card_DCLTD
select	t1.sku_number,
		isnull(sum(t2.current_Units),0) as DCLTD_Units,
		isnull(sum(t2.Current_Dollars),0) as DCLTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.internet_weekly_sales t2
		on t2.sku_number = t1.sku_number
group by t1.sku_number
--
truncate table staging.dbo.wrk_Card_LTD
insert into staging.dbo.wrk_Card_LTD
select	t1.sku_number,
		LifeTodateUnits as LTD_Units,
		LifeToDateDollars as LTD_Dollars
from	reference.dbo.item_master t1 
		left join reference.dbo.invcbl t2
		on t2.sku_number = t1.sku_number
--
select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)

select @seldate
truncate table staging.dbo.wrk_Card_WTD
insert into
 staging.dbo.wrk_Card_WTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as WTD_Units,
		isnull(sum(t2.Extended_Price),0) as WTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and t2.store_number >= 100 and t2.store_number <= 980
		and t2.day_date > @seldate
group by t1.sku_number
--
select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)
truncate table staging.dbo.wrk_Card_DCWTD
insert into staging.dbo.wrk_Card_DCWTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as DCWTD_Units,
		isnull(sum(t2.Extended_Price),0) as DCWTD_Dollars
from	reference.dbo.item_master t1 
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
from	reference.dbo.item_display_min
group by sku_number


--
-- Create On-Hands from invbal
--
truncate table staging.dbo.wrk_inv_onhands_All
insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	reference.dbo.invcbl
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
select	ISBN,
		isnull(sum(onhand),0) as OnHand
from	reference.dbo.WMBAL
where	left(location,1) in ('7','8','9')
group by ISBN

insert into Staging.dbo.wrk_Card_Inventory
select	reference.dbo.item_master.sku_number,
		Reference.dbo.ITBAL.WarehouseID,
		isnull(#display_min.Display_Min,0) as Store_Min,
		isnull(staging.dbo.wrk_inv_onhands.on_hand,0) as BAM_OnHand,
		Isnull(Reference.dbo.INVCBL.POOnOrder,0) as BAM_OnOrder,
		isnull(Reference.dbo.ITBAL.OnHand,0) AS Warehouse_OnHand, 
		isnull(Reference.dbo.ITBAL.OnPO,0) AS Qty_OnOrder, 
		isnull(Reference.dbo.ITBAL.OnBackOrder,0) AS Qty_OnBackorder, 
		isnull(Reference.dbo.ITBAL.InTransit,0) as InTransit,
		isnull(staging.dbo.wrk_card_wmbal.OnHand,0) as ReturnCenter_OnHand,
		case
			when (staging.dbo.wrk_inv_onhands.On_Hand + isnull(Reference.dbo.ITBAL.OnHand,0)) < 0
			then 0
		else
			isnull(staging.dbo.wrk_inv_onhands.On_Hand,0) + isnull(Reference.dbo.ITBAL.OnHand,0) 
		End AS Total_OnHand
from	reference.dbo.item_master 
		left join reference.dbo.invcbl
		on reference.dbo.invcbl.sku_number = reference.dbo.item_master.sku_number
		left join reference.dbo.itbal
		on reference.dbo.itbal.sku_number = reference.dbo.item_master.sku_number
		left join #display_min
		on #display_min.sku_number = reference.dbo.item_master.sku_number
		left join staging.dbo.wrk_inv_onhands
		on staging.dbo.wrk_inv_onhands.sku_number = reference.dbo.item_master.sku_number
		left join staging.dbo.wrk_card_wmbal on staging.dbo.wrk_card_wmbal.ISBN = reference.dbo.item_master.ISBN
--
update Staging.dbo.wrk_Card_Inventory
set Store_Min = (select isnull(sum(Display_Min),0) from reference.dbo.item_display_min
				where reference.dbo.item_display_min.sku_number = Staging.dbo.wrk_Card_Inventory.sku_number)
where Store_Min = 0
--
-- End of work table construction
--
-- Combine work tables into single table
--
truncate table Staging.dbo.tmp_CARD
--
--
insert into Staging.dbo.tmp_CARD
SELECT	t1.ISBN, 
		t1.Sku_Number AS SKU, 
		t1.EAN,
		t1.DW_ISBN,
		t1.Title, 
		t1.Status, 
		t1.Pub_Code AS Pub_Code,
		t1.Publisher, 
		t1.VIN,
		t1.Author,
		t1.returnable,
		t1.Disposition,
		t1.Sr_Buyer_Name,
		t1.BuyerName,
		t1.Buyer_Number,
		t1.Dept AS Dept, 
		t1.Dept_Name as Dept_Name, 
		t1.SDept AS SDept, 
		t1.SDept_Name as SDept_Name, 
		t1.Class AS Class, 
		t1.Class_Name as Class_Name, 
		t1.SClass AS SClass, 
		t1.SClass_Name as SClass_Name, 
		t1.Module, 
		t1.SKU_Type AS Sku_Type, 
		t1.Subject,
		t1.strength,
		0 as Bookscan_Rank, 
		0 as Internet_Rank, 
		NULL as BAM_WOS,
		NULL as AWBC_WOS,
		case
			When t3.Week1Units > 0 and t4.BAM_OnHand > 0 and t3.Week1Units > 0
			then t3.Week1Units/(t3.Week1Units+t4.BAM_OnHand)
			else
				0
		end as Sell_Thru,
		t1.Vendor_Cost,
		t1.Retail, 
		t1.Coordinate_Group, 
		t1.Season,
		t1.IDate, 
		t1.ExpReceiptDate,
		t4.Store_Min,
		t1.Min_Qty,
		t1.Max_Qty,
		isnull(t8.IBCSQT,0),
		t4.BAM_OnHand,
		t4.BAM_OnOrder,
		t4.Warehouse_OnHand, 
		t4.ReturnCenter_OnHand,
		t4.Qty_OnOrder, 
		t4.Qty_OnBackorder, 
		t4.InTransit,
		t4.Total_OnHand,
		NULL as NumStocked,
		isnull(t3.Week1Units,0) as Week1Units,
		isnull(t3.Week1Dollars, 0) as Week1Dollars,
		isnull(t3.Week2Units,0) as  Week2Units,
		isnull(t3.Week2Dollars, 0) as Week2dollars,
		isnull(t3.Week3Units, 0) as week3units,
		isnull(t3.Week3Dollars, 0) as week3dollars,
		isnull(t3.DCWeek1Units, 0) as dcweek1units,
		isnull(t3.DCWeek1Dollars, 0) as dcweek1dollars,
		isnull(t3.DCWeek2Units, 0) as dcweek2units,
		isnull(t3.DCWeek2Dollars, 0) as dcweek2dollars,
		isnull(t3.DCWeek3Units, 0) as dcweek3units,
		isnull(t3.DCWeek3Dollars, 0) as dcweek3dollars,
		isnull(t3.lyWeek1Units, 0) as lyweek1units,
		isnull(t3.lyWeek1Dollars, 0) as lyweek1dollars,
		isnull(t3.lyWeek2Units, 0) as lyweek2units,
		isnull(t3.lyWeek2Dollars, 0) as lyweek2dollars,
		isnull(t3.lyWeek3Units, 0) as lyweek3units,
		isnull(t3.lyWeek3Dollars, 0) as lyweek3dollars,
		isnull(t3.lyDCWeek1Units, 0) as lydcweek1units,
		isnull(t3.lyDCWeek1Dollars, 0) as lydcweek1dollars ,
		isnull(t3.lyDCWeek2Units, 0) as lydcweek2units,
		isnull(t3.lyDCWeek2Dollars, 0) as lydcweek2dollars,
		isnull(t3.lyDCWeek3Units, 0) as lydcweek3units,
		isnull(t3.lyDCWeek3Dollars, 0) as lydcweek3dollars,
		isnull(t3.TYYTDUnits, 0) as TYYTDUnits,
		isnull(t3.TYYTDDollars, 0) as TYYTDDollars,
		isnull(t3.LYYTDUnits, 0) as LYYTDUnits,
		isnull(t3.LYYTDDollars, 0) as LYYTDDollars,
		isnull(t3.DCTYYTDUnits, 0) as DCTYYTDUnits,
		isnull(t3.DCTYYTDDollars, 0) as DCTYYTDDollars,
		isnull(t3.DCLYYTDUnits, 0) as DCLYYTDUnits,
		isnull(t3.DCLYYTDDollars, 0) as DCLYYTDDollars,
		isnull(t3.Week13Units, 0) as Week13units,
		isnull(t3.Week13Dollars, 0) as week13dollars,
		isnull(t3.DCWeek13Units, 0) as dcweek13units,
		isnull(t3.DCWeek13Dollars, 0) as dcweek13dollars,
		isnull(t5.WTD_Units,0) as wtd_units,
		isnull(t5.WTD_Dollars,0) as wtd_dollars,
		isnull(t9.DCWTD_Units,0) as DCwtd_units,
		isnull(t9.DCWTD_Dollars,0) as DCwtd_dollars,
		isnull(t6.LTD_Units,0) as ltd_units,
		isnull(t6.LTD_Dollars, 0) as ltd_dollars,
		isnull(t7.DCLTD_UNITS,0) as dcltd_units,
		isnull(t7.DCLTD_DOLLARS,0) as dcltd_dollars,
		t4.Warehouse_ID,
		getdate() as Load_Date 
FROM	staging.dbo.wrk_card_descriptive t1
		left join dssdata.dbo.three_week_sales t3
		on t3.sku_number = t1.sku_number
		left join staging.dbo.wrk_card_Inventory t4
		on t4.sku_number = t1.sku_number
		left join staging.dbo.wrk_card_WTD t5
		on t5.sku_number = t1.sku_number
		left join staging.dbo.wrk_card_LTD t6
		on t6.sku_number = t1.sku_number
		left join staging.dbo.wrk_card_DCLTD t7
		on t7.sku_number = t1.sku_number
		left join reference.dbo.ITWHM t8
		on t8.ibitno = t1.isbn
		left join staging.dbo.wrk_CARD_DCWTD t9
		on t9.sku_number = t1.sku_number

--
--update staging.dbo.tmp_card
--set store_min = (select sum(Display_Min) from reference.dbo.Item_Display_Min
--where reference.dbo.Item_Display_Min.sku_number = staging.dbo.tmp_card.sku_number)
--where staging.dbo.tmp_card.dept NOT IN (1,4,8)
--
truncate table dssdata.dbo.card
----
insert into dssdata.dbo.CARD

select distinct * from staging.dbo.tmp_card
GO
