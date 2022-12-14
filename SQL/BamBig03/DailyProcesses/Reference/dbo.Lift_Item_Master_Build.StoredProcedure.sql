USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[Lift_Item_Master_Build]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Lift_Item_Master_Build]
AS
TRUNCATE TABLE reference.dbo.Item_Master_Lift
INSERT INTO reference.dbo.Item_Master_Lift
SELECT        ISBN, SKU_Number, Sku_Text, EAN, SKU_Type, REPLACE(REPLACE([Title],'|', ''), ':', '') AS Title, REPLACE(REPLACE([Description],'|', ''), ':', '') AS Description, Author, Returnable, Status, PubCode, Publisher, Vendor_Number, Vendors_Number, Manuf_Number, Manufs_Number, MfgItemNo, Repl_Code, 
                         Module, Dept, SDept, Class, SClass, Category, Dept_Name, SDept_Name, Class_Name, SClass_Name, Buyer_Number, BuyerName, Merch_Group_Number, Coordinate_Group, Manuf_List_Price, Home_Cost, 
                         Vendor_Cost, POS_Price, Initial_Home_Cost, SuspendCode, VoidFlag, Disposition, ILevel, Level_Ind, Min_Qty, Max_Qty, Load_Date, Condition

FROM            Reference.dbo.Item_Master
GO
