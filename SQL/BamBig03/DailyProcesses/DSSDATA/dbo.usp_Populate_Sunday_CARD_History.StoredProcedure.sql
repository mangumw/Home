USE [Dssdata]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Sunday_CARD_History]    Script Date: 8/19/2022 3:48:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[usp_Populate_Sunday_CARD_History]
as
delete from Dssdata.dbo.Sunday_CARD_History2 where day_date = staging.dbo.fn_dateonly(getdate()-1)
--
insert into Dssdata.dbo.Sunday_CARD_History2
select	staging.dbo.fn_DateOnly(Load_Date - 1) as day_date,
ISBN,Sku_Number,EAN,DW_ISBN,Title,Status,Pub_Code,Publisher,VIN,Author,Returnable,Disposition,Sr_Buyer,Buyer,Buyer_Number,Dept,Dept_Name,
SDept,SDept_Name,Class,Class_Name,SClass,SClass_Name,Module,Sku_Type,Subject,Strength,Bookscan_Rank,Internet_Rank,BAM_WOS,AWBC_WOS,Sell_Thru,DWCost,
Retail,Coordinate_Group,Season,IDate,ExpReceiptDate,Store_Min,Min_Qty,Max_Qty,Case_Qty,BAM_OnHand,BAM_OnOrder,Warehouse_OnHand,ReturnCenter_OnHand,
Qty_OnOrder,Qty_OnBackorder,InTransit,Total_OnHand,Stocked_Stores,Week1Units,Week1Dollars,Week2Units,Week2Dollars,Week3Units,Week3Dollars,DCWeek1Units,
DCWeek1Dollars,DCWeek2Units,DCWeek2Dollars,DCWeek3Units,DCWeek3Dollars,lyWeek1Units,lyWeek1Dollars,lyWeek2Units,lyWeek2Dollars,lyWeek3Units,lyWeek3Dollars,
lyDCWeek1Units,lyDCWeek1Dollars,lyDCWeek2Units,lyDCWeek2Dollars,lyDCWeek3Units,lyDCWeek3Dollars,TYYTDUnits,TYYTDDollars,LYYTDUnits,LYYTDDollars,DCTYYTDUnits,
DCTYYTDDollars,DCLYYTDUnits,DCLYYTDDollars,Week13Units,Week13Dollars,DCWeek13Units,DCWeek13Dollars,WTD_Units,WTD_Dollars,DCWTD_Units,DCWTD_Dollars,LTD_Units,
LTD_Dollars,DCLTD_Units,DCLTD_Dollars,WarehouseID,BowkerStatus,IATRB3,Load_Date,Condition
from Dssdata.dbo.CARD








GO
