USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_jenny_store_counts]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure
[dbo].[usp_jenny_store_counts] as



SELECT     RTVTRNH.Debit_Number, RTVTRN_SC.Store_Qty AS Store_Count, RTVTRN_SC.MMS_OH, RTVTRN_SC.Return_Date, Item_Master.ISBN, Item_Master.Title, 
                      Item_Master.Author, Item_Master.SDept_Name, Item_Master.Class_Name, Staging.dbo.jenny_counts2.ID, Staging.dbo.jenny_counts2.SKU, 
                      Staging.dbo.jenny_counts2.Store_Number, Staging.dbo.jenny_counts2.Region_Number, Staging.dbo.jenny_counts2.district_number
FROM         RTVTRNH INNER JOIN
                      RTVTRN_SC ON RTVTRNH.Debit_Number = RTVTRN_SC.Debit_Number AND RTVTRNH.Store_Number = RTVTRN_SC.Store_Number INNER JOIN
                      Item_Master ON RTVTRN_SC.Sku_Number = Item_Master.SKU_Number RIGHT OUTER JOIN
                      Staging.dbo.jenny_counts2 ON RTVTRN_SC.Sku_Number = Staging.dbo.jenny_counts2.SKU AND 
                      RTVTRN_SC.Store_Number = Staging.dbo.jenny_counts2.Store_Number
WHERE     (RTVTRNH.Scan_Code = 'C') AND (RTVTRN_SC.Return_Date BETWEEN CONVERT(DATETIME, '2010-01-01 00:00:00', 102) AND CONVERT(DATETIME, 
                      '2010-05-05 00:00:00', 102))

---- PART 1  cartisian join all jenny_counts and active stores table -------- 
truncate table staging.dbo.jenny_counts2
insert into staging.dbo.jenny_counts2
SELECT     Staging.dbo.jenny_counts.ID, Staging.dbo.jenny_counts.SKU, Active_Stores.Store_Number, Active_Stores.Region_Number, 
                      Active_Stores.district_number
FROM         Staging.dbo.jenny_counts CROSS JOIN
                      Active_Stores

select * from staging.dbo.jenny_counts2
-------- PART 2 make table for next join ----------------------
truncate table staging.dbo.jenny_counts3
insert into staging.dbo.jenny_counts3
SELECT     Staging.dbo.jenny_counts2.ID, Staging.dbo.jenny_counts2.SKU, Staging.dbo.jenny_counts2.Store_Number, 
                      Staging.dbo.jenny_counts2.Region_Number, Staging.dbo.jenny_counts2.district_number, RTVTRN_SC.Store_Qty AS Store_Count, 
                      RTVTRN_SC.MMS_OH, RTVTRN_SC.Return_Date
FROM         Staging.dbo.jenny_counts2 LEFT OUTER JOIN
                      RTVTRN_SC ON Staging.dbo.jenny_counts2.SKU = RTVTRN_SC.Sku_Number AND 
                      Staging.dbo.jenny_counts2.Store_Number = RTVTRN_SC.Store_Number
--------- PART 3 append item master detail -----------------------
truncate table staging.dbo.jenny_counts6
insert into staging.dbo.jenny_counts6
SELECT     Staging.dbo.jenny_counts3.ID, Staging.dbo.jenny_counts3.SKU, Item_Master.ISBN, Item_Master.Title, Item_Master.Author, Item_Master.SDept_Name, 
                      Item_Master.Class_Name, Staging.dbo.jenny_counts3.Store_Number, Staging.dbo.jenny_counts3.Region_Number, 
                      Staging.dbo.jenny_counts3.district_number, Staging.dbo.jenny_counts3.Store_Count, Staging.dbo.jenny_counts3.MMS_OH, 
                      Staging.dbo.jenny_counts3.Return_Date
FROM         Staging.dbo.jenny_counts3 INNER JOIN
                      Item_Master ON Staging.dbo.jenny_counts3.SKU = Item_Master.SKU_Number


GO
