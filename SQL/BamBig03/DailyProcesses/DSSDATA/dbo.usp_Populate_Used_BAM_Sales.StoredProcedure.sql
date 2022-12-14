USE [Dssdata]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Used_BAM_Sales]    Script Date: 8/19/2022 3:48:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Populate_Used_BAM_Sales]
as
--delete from dssdata.dbo.Used_BAM_Sales where day_date = staging.dbo.fn_dateonly(getdate())

truncate table dssdata.dbo.Used_BAM_Sales
--
insert into DssData.dbo.Used_BAM_Sales
select Day_Date,Store_Number,Register_Nbr,Transaction_Nbr,Sequence_Nbr,Transaction_Code,Transaction_Time,Cashier_Nbr,Sku_Number,ISBN,
Item_Quantity,Unit_Retail,Unit_Cost,Extended_Price,Extended_Discount,Price_Override,UPC_Number,Unit_Regular_Price,Reason_Code,
Customer_Number,Load_Date,Dept, staging.dbo.fn_Convert_Isbn_13(UPC_Number) as Identifier 
from Dssdata.dbo.detail_transaction_history 
where Dept = 95 and len(UPC_Number) = 13

insert into DssData.dbo.Used_BAM_Sales
select Day_Date,Store_Number,Register_Nbr,Transaction_Nbr,Sequence_Nbr,Transaction_Code,Transaction_Time,Cashier_Nbr,Sku_Number,ISBN,
Item_Quantity,Unit_Retail,Unit_Cost,Extended_Price,Extended_Discount,Price_Override,UPC_Number,Unit_Regular_Price,Reason_Code,
Customer_Number,Load_Date,Dept, UPC_Number as Identifier 
from Dssdata.dbo.detail_transaction_history 
where Dept = 95 and len(UPC_Number) <> 13





GO
