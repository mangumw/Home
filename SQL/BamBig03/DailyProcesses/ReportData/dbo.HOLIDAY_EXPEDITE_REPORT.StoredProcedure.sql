USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[HOLIDAY_EXPEDITE_REPORT]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HOLIDAY_EXPEDITE_REPORT]
AS
truncate table tmp_load.dbo.expedite1a
insert into tmp_load.dbo.expedite1a
SELECT        TOP (150) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, 
                         Qty_OnBackorder, Week1Units, Week2Units, Week3Units
FROM            Dssdata.dbo.CARD
WHERE        (Dept = 1) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC
insert into tmp_load.dbo.expedite1a
SELECT     TOP (150) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 5) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (1000) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 4) AND (Sku_Type IN ('T', 'N','R','B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (1000) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 6) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (50) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 8) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (50) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, Warehouse_OnHand, 
                      ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units
FROM         DssData.dbo.CARD
WHERE     (Dept IN (71, 74, 75)) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (75) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 58) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC


insert into tmp_load.dbo.expedite1a
SELECT     TOP (50) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 69) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC

insert into tmp_load.dbo.expedite1a
SELECT     TOP (150) ISBN, Sku_Number, EAN, Title, Author, Buyer, Buyer_Number, Dept, SDept_Name, SDept, Class_Name, Class, Sku_Type, Retail, 
                      Warehouse_OnHand, ReturnCenter_OnHand, Qty_OnOrder, Qty_OnBackorder, Week1Units, Week2Units, Week3Units

FROM         DssData.dbo.CARD
WHERE     (Dept = 9) AND (Sku_Type IN ('T', 'N', 'R', 'B')) AND (Condition = 'NEW')
ORDER BY Week1Units DESC
----- REBUILD TABLE
truncate table tmp_load.dbo.expedite1ddd
insert into tmp_load.dbo.expedite1ddd

SELECT     
Tmp_Load.dbo.expedite1a.ISBN, 
Tmp_Load.dbo.expedite1a.Sku_Number, 
Tmp_Load.dbo.expedite1a.EAN, 
Tmp_Load.dbo.expedite1a.Title, 
Tmp_Load.dbo.expedite1a.Author, 
Tmp_Load.dbo.expedite1a.Buyer, 
Tmp_Load.dbo.expedite1a.Buyer_Number, 
Tmp_Load.dbo.expedite1a.Dept, 
Tmp_Load.dbo.expedite1a.SDept_Name, 
Tmp_Load.dbo.expedite1a.SDept, 
Tmp_Load.dbo.expedite1a.Class_Name, 
Tmp_Load.dbo.expedite1a.Class, 
Tmp_Load.dbo.expedite1a.Sku_Type, 
Tmp_Load.dbo.expedite1a.Retail, 
Tmp_Load.dbo.expedite1a.Warehouse_OnHand, 
Tmp_Load.dbo.expedite1a.ReturnCenter_OnHand, 
Tmp_Load.dbo.expedite1a.Qty_OnOrder, 
Reference.dbo.Item_Display_Min.Store_Number, 
Reference.dbo.Item_Display_Min.Display_Min, 
Reference.dbo.INVBAL.In_Transit as On_Hand, 
Reference.dbo.INVBAL.In_Transit as On_Order, 
Reference.dbo.INVBAL.IBWKCR, 
Reference.dbo.INVBAL.Wk1_SLSU

FROM         Tmp_Load.dbo.expedite1a INNER JOIN
                      Reference.dbo.Item_Display_Min ON Tmp_Load.dbo.expedite1a.Sku_Number = Reference.dbo.Item_Display_Min.Sku_Number INNER JOIN
                      Reference.dbo.INVBAL ON Reference.dbo.Item_Display_Min.Sku_Number = Reference.dbo.INVBAL.sku_number AND 
                      Reference.dbo.Item_Display_Min.Store_Number = Reference.dbo.INVBAL.Store_Number
WHERE     (Reference.dbo.Item_Display_Min.Display_Min > 0) AND (Reference.dbo.Item_Display_Min.Store_Number > 101)

SELECT     
Tmp_Load.dbo.expedite1ddd.ISBN, 
Tmp_Load.dbo.expedite1ddd.Sku_Number, 
Tmp_Load.dbo.expedite1ddd.EAN, 
Tmp_Load.dbo.expedite1ddd.Title, 
Tmp_Load.dbo.expedite1ddd.Author, 
Tmp_Load.dbo.expedite1ddd.Buyer, 
Tmp_Load.dbo.expedite1ddd.Buyer_Number, 
Tmp_Load.dbo.expedite1ddd.Dept, 
Tmp_Load.dbo.expedite1ddd.SDept_Name, 
Tmp_Load.dbo.expedite1ddd.SDept, 
Tmp_Load.dbo.expedite1ddd.Class_Name, 
Tmp_Load.dbo.expedite1ddd.Class, 
Tmp_Load.dbo.expedite1ddd.Sku_Type, 
Tmp_Load.dbo.expedite1ddd.Retail, 
Tmp_Load.dbo.expedite1ddd.Warehouse_OnHand, 
Tmp_Load.dbo.expedite1ddd.ReturnCenter_OnHand, 
Tmp_Load.dbo.expedite1ddd.Qty_OnOrder, 
Tmp_Load.dbo.expedite1ddd.Store_Number, 
Tmp_Load.dbo.expedite1ddd.Display_Min, 
Tmp_Load.dbo.expedite1ddd.On_Hand, 
Tmp_Load.dbo.expedite1ddd.On_Order, 
Tmp_Load.dbo.expedite1ddd.IBWKCR, 
Tmp_Load.dbo.expedite1ddd.Wk1_SLSU, 
Tmp_Load.dbo.dept_build.build * Tmp_Load.dbo.expedite1ddd.IBWKCR AS forecast, 
Tmp_Load.dbo.dept_build.build * Tmp_Load.dbo.expedite1ddd.IBWKCR - (Tmp_Load.dbo.expedite1ddd.On_Hand + Tmp_Load.dbo.expedite1ddd.On_Order)
                       AS coverage, 
Reference.dbo.Route_Guide.PTDDAY, 
Reference.dbo.INVMST.Inner_Pack
FROM         
Reference.dbo.INVMST 
INNER JOIN
Tmp_Load.dbo.expedite1ddd ON Reference.dbo.INVMST.Sku_Number = Tmp_Load.dbo.expedite1ddd.Sku_Number 
INNER JOIN
Tmp_Load.dbo.dept_build ON Tmp_Load.dbo.expedite1ddd.Dept = Tmp_Load.dbo.dept_build.dept 
INNER JOIN
Reference.dbo.Route_Guide ON Tmp_Load.dbo.expedite1ddd.Store_Number = Reference.dbo.Route_Guide.PTSTOR#
GO
