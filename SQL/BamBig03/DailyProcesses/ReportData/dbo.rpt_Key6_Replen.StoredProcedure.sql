USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Key6_Replen]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[rpt_Key6_Replen] AS

truncate table tmp_load.dbo.colpack1

insert into tmp_load.dbo.colpack1

SELECT     DssData.dbo.CARD.Dept, DssData.dbo.CARD.Class, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Title, 
                      DssData.dbo.CARD.Author, DssData.dbo.CARD.Pub_Code, DssData.dbo.CARD.Sku_Type, DssData.dbo.CARD.Retail, DssData.dbo.CARD.BAM_OnHand, 
                      DssData.dbo.CARD.InTransit, DssData.dbo.CARD.BAM_OnOrder, DssData.dbo.CARD.Warehouse_OnHand, DssData.dbo.CARD.ReturnCenter_OnHand, 
                      DssData.dbo.CARD.Qty_OnOrder, DssData.dbo.CARD.Qty_OnBackorder, DssData.dbo.CARD.Status, DssData.dbo.CARD.IDate, 
                      DssData.dbo.CARD.Store_Min, DssData.dbo.CARD.Case_Qty, DssData.dbo.Weekly_Sales.Day_Date, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS week1
FROM         DssData.dbo.CARD LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON DssData.dbo.CARD.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
GROUP BY DssData.dbo.CARD.Dept, DssData.dbo.CARD.Class, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Title, 
                      DssData.dbo.CARD.Author, DssData.dbo.CARD.Pub_Code, DssData.dbo.CARD.Sku_Type, DssData.dbo.CARD.Retail, DssData.dbo.CARD.BAM_OnHand, 
                      DssData.dbo.CARD.InTransit, DssData.dbo.CARD.BAM_OnOrder, DssData.dbo.CARD.Warehouse_OnHand, DssData.dbo.CARD.ReturnCenter_OnHand, 
                      DssData.dbo.CARD.Qty_OnOrder, DssData.dbo.CARD.Qty_OnBackorder, DssData.dbo.CARD.Status, DssData.dbo.CARD.IDate, 
                      DssData.dbo.CARD.Store_Min, DssData.dbo.CARD.Case_Qty, DssData.dbo.Weekly_Sales.Day_Date
HAVING      (DssData.dbo.CARD.Dept = 6) AND (DssData.dbo.CARD.Sku_Type IN ('T', 'N', 'R', 'B')) AND (DssData.dbo.CARD.Status = 'A') AND 
                      (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE())) AND (DssData.dbo.CARD.Store_Min > 0)
------------------------------------- Next Week ------------------------------------------------------
truncate table tmp_load.dbo.colpack2

insert into tmp_load.dbo.colpack2

SELECT     Tmp_Load.dbo.colpack1.Dept, Tmp_Load.dbo.colpack1.Class, Tmp_Load.dbo.colpack1.Sku_Number, Tmp_Load.dbo.colpack1.ISBN, 
                      Tmp_Load.dbo.colpack1.Title, Tmp_Load.dbo.colpack1.Author, Tmp_Load.dbo.colpack1.Pub_Code, Tmp_Load.dbo.colpack1.Sku_Type, 
                      Tmp_Load.dbo.colpack1.Retail, Tmp_Load.dbo.colpack1.BAM_OnHand, Tmp_Load.dbo.colpack1.InTransit, Tmp_Load.dbo.colpack1.BAM_OnOrder, 
                      Tmp_Load.dbo.colpack1.Warehouse_OnHand, Tmp_Load.dbo.colpack1.ReturnCenter_OnHand, Tmp_Load.dbo.colpack1.Qty_OnOrder, 
                      Tmp_Load.dbo.colpack1.Qty_OnBackorder, Tmp_Load.dbo.colpack1.Status, Tmp_Load.dbo.colpack1.IDate, Tmp_Load.dbo.colpack1.Store_Min, 
                      Tmp_Load.dbo.colpack1.Case_Qty, Tmp_Load.dbo.colpack1.week1, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week2
FROM      Tmp_Load.dbo.colpack1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON Tmp_Load.dbo.colpack1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 7))
GROUP BY Tmp_Load.dbo.colpack1.Dept, Tmp_Load.dbo.colpack1.Class, Tmp_Load.dbo.colpack1.Sku_Number, Tmp_Load.dbo.colpack1.ISBN, 
                      Tmp_Load.dbo.colpack1.Title, Tmp_Load.dbo.colpack1.Author, Tmp_Load.dbo.colpack1.Pub_Code, Tmp_Load.dbo.colpack1.Sku_Type, 
                      Tmp_Load.dbo.colpack1.Retail, Tmp_Load.dbo.colpack1.BAM_OnHand, Tmp_Load.dbo.colpack1.InTransit, Tmp_Load.dbo.colpack1.BAM_OnOrder, 
                      Tmp_Load.dbo.colpack1.Warehouse_OnHand, Tmp_Load.dbo.colpack1.ReturnCenter_OnHand, Tmp_Load.dbo.colpack1.Qty_OnOrder, 
                      Tmp_Load.dbo.colpack1.Qty_OnBackorder, Tmp_Load.dbo.colpack1.Status, Tmp_Load.dbo.colpack1.IDate, Tmp_Load.dbo.colpack1.Store_Min, 
                      Tmp_Load.dbo.colpack1.Case_Qty, Tmp_Load.dbo.colpack1.week1
------------------------------------------------------
truncate table tmp_load.dbo.colpack3

insert into tmp_load.dbo.colpack3
SELECT     Tmp_Load.dbo.colpack2.Dept, Tmp_Load.dbo.colpack2.Class, Tmp_Load.dbo.colpack2.Sku_Number, Tmp_Load.dbo.colpack2.ISBN, 
                      Tmp_Load.dbo.colpack2.Title, Tmp_Load.dbo.colpack2.Author, Tmp_Load.dbo.colpack2.Pub_Code, Tmp_Load.dbo.colpack2.Sku_Type, 
                      Tmp_Load.dbo.colpack2.Retail, Tmp_Load.dbo.colpack2.BAM_OnHand, Tmp_Load.dbo.colpack2.InTransit, Tmp_Load.dbo.colpack2.BAM_OnOrder, 
                      Tmp_Load.dbo.colpack2.Warehouse_OnHand, Tmp_Load.dbo.colpack2.ReturnCenter_OnHand, Tmp_Load.dbo.colpack2.Qty_OnOrder, 
                      Tmp_Load.dbo.colpack2.Qty_OnBackorder, Tmp_Load.dbo.colpack2.Status, Tmp_Load.dbo.colpack2.IDate, Tmp_Load.dbo.colpack2.Store_Min, 
                      Tmp_Load.dbo.colpack2.Case_Qty, Tmp_Load.dbo.colpack2.week1, Tmp_Load.dbo.colpack2.week2, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS week3
FROM         Tmp_Load.dbo.colpack2 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON Tmp_Load.dbo.colpack2.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 14))
GROUP BY Tmp_Load.dbo.colpack2.Dept, Tmp_Load.dbo.colpack2.Class, Tmp_Load.dbo.colpack2.Sku_Number, Tmp_Load.dbo.colpack2.ISBN, 
                      Tmp_Load.dbo.colpack2.Title, Tmp_Load.dbo.colpack2.Author, Tmp_Load.dbo.colpack2.Pub_Code, Tmp_Load.dbo.colpack2.Sku_Type, 
                      Tmp_Load.dbo.colpack2.Retail, Tmp_Load.dbo.colpack2.BAM_OnHand, Tmp_Load.dbo.colpack2.InTransit, Tmp_Load.dbo.colpack2.BAM_OnOrder, 
                      Tmp_Load.dbo.colpack2.Warehouse_OnHand, Tmp_Load.dbo.colpack2.ReturnCenter_OnHand, Tmp_Load.dbo.colpack2.Qty_OnOrder, 
                      Tmp_Load.dbo.colpack2.Qty_OnBackorder, Tmp_Load.dbo.colpack2.Status, Tmp_Load.dbo.colpack2.IDate, Tmp_Load.dbo.colpack2.Store_Min, 
                      Tmp_Load.dbo.colpack2.Case_Qty, Tmp_Load.dbo.colpack2.week1, Tmp_Load.dbo.colpack2.week2
-----------------------------------------------------
TRUNCATE TABLE		  tmp_load.dbo.colpack4
INSERT  INTO		  tmp_load.dbo.colpack4
SELECT     colpack3_1.Dept, colpack3_1.Class, colpack3_1.Sku_Number, colpack3_1.ISBN, colpack3_1.Title, colpack3_1.Author, colpack3_1.Pub_Code, 
                      colpack3_1.Sku_Type, colpack3_1.Retail, colpack3_1.BAM_OnHand, colpack3_1.InTransit, colpack3_1.BAM_OnOrder, 
                      colpack3_1.Warehouse_OnHand, colpack3_1.ReturnCenter_OnHand, colpack3_1.Qty_OnOrder, colpack3_1.Qty_OnBackorder, colpack3_1.Status, 
                      colpack3_1.IDate, colpack3_1.Store_Min, colpack3_1.Case_Qty, colpack3_1.week1, colpack3_1.week2, colpack3_1.week3, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week4
FROM         tmp_load.dbo.colpack3 AS colpack3_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack3_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 21))
GROUP BY colpack3_1.Dept, colpack3_1.Class, colpack3_1.Sku_Number, colpack3_1.ISBN, colpack3_1.Title, colpack3_1.Author, colpack3_1.Pub_Code, 
                      colpack3_1.Sku_Type, colpack3_1.Retail, colpack3_1.BAM_OnHand, colpack3_1.InTransit, colpack3_1.BAM_OnOrder, 
                      colpack3_1.Warehouse_OnHand, colpack3_1.ReturnCenter_OnHand, colpack3_1.Qty_OnOrder, colpack3_1.Qty_OnBackorder, colpack3_1.Status, 
                      colpack3_1.IDate, colpack3_1.Store_Min, colpack3_1.Case_Qty, colpack3_1.week1, colpack3_1.week2, colpack3_1.week3

----------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack5
INSERT INTO Tmp_Load.dbo.colpack5
SELECT     colpack4_1.Dept, colpack4_1.Class, colpack4_1.Sku_Number, colpack4_1.ISBN, colpack4_1.Title, colpack4_1.Author, colpack4_1.Pub_Code, 
                      colpack4_1.Sku_Type, colpack4_1.Retail, colpack4_1.BAM_OnHand, colpack4_1.InTransit, colpack4_1.BAM_OnOrder, 
                      colpack4_1.Warehouse_OnHand, colpack4_1.ReturnCenter_OnHand, colpack4_1.Qty_OnOrder, colpack4_1.Qty_OnBackorder, colpack4_1.Status, 
                      colpack4_1.IDate, colpack4_1.Store_Min, colpack4_1.Case_Qty, colpack4_1.week1, colpack4_1.week2, colpack4_1.week3, colpack4_1.week4, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week5
FROM         Tmp_Load.dbo.colpack4 AS colpack4_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack4_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 28))
GROUP BY colpack4_1.Dept, colpack4_1.Class, colpack4_1.Sku_Number, colpack4_1.ISBN, colpack4_1.Title, colpack4_1.Author, colpack4_1.Pub_Code, 
                      colpack4_1.Sku_Type, colpack4_1.Retail, colpack4_1.BAM_OnHand, colpack4_1.InTransit, colpack4_1.BAM_OnOrder, 
                      colpack4_1.Warehouse_OnHand, colpack4_1.ReturnCenter_OnHand, colpack4_1.Qty_OnOrder, colpack4_1.Qty_OnBackorder, colpack4_1.Status, 
                      colpack4_1.IDate, colpack4_1.Store_Min, colpack4_1.Case_Qty, colpack4_1.week1, colpack4_1.week2, colpack4_1.week3, colpack4_1.week4

------------------------------------------------------------------------
TRUNCATE TABLE tmp_load.dbo.colpack6
INSERT INTO tmp_load.dbo.colpack6
SELECT     colpack5_1.Dept, colpack5_1.Class, colpack5_1.Sku_Number, colpack5_1.ISBN, colpack5_1.Title, colpack5_1.Author, colpack5_1.Pub_Code, 
                      colpack5_1.Sku_Type, colpack5_1.Retail, colpack5_1.BAM_OnHand, colpack5_1.InTransit, colpack5_1.BAM_OnOrder, 
                      colpack5_1.Warehouse_OnHand, colpack5_1.ReturnCenter_OnHand, colpack5_1.Qty_OnOrder, colpack5_1.Qty_OnBackorder, colpack5_1.Status, 
                      colpack5_1.IDate, colpack5_1.Store_Min, colpack5_1.Case_Qty, colpack5_1.week1, colpack5_1.week2, colpack5_1.week3, colpack5_1.week4, 
                      colpack5_1.week5, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week6
FROM         Tmp_Load.dbo.colpack5 AS colpack5_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack5_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 35))
GROUP BY colpack5_1.Dept, colpack5_1.Class, colpack5_1.Sku_Number, colpack5_1.ISBN, colpack5_1.Title, colpack5_1.Author, colpack5_1.Pub_Code, 
                      colpack5_1.Sku_Type, colpack5_1.Retail, colpack5_1.BAM_OnHand, colpack5_1.InTransit, colpack5_1.BAM_OnOrder, 
                      colpack5_1.Warehouse_OnHand, colpack5_1.ReturnCenter_OnHand, colpack5_1.Qty_OnOrder, colpack5_1.Qty_OnBackorder, colpack5_1.Status, 
                      colpack5_1.IDate, colpack5_1.Store_Min, colpack5_1.Case_Qty, colpack5_1.week1, colpack5_1.week2, colpack5_1.week3, colpack5_1.week4, 
                      colpack5_1.week5
----------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack7

INSERT INTO Tmp_Load.dbo.colpack7
SELECT     colpack6_1.Dept, colpack6_1.Class, colpack6_1.Sku_Number, colpack6_1.ISBN, colpack6_1.Title, colpack6_1.Author, colpack6_1.Pub_Code, 
                      colpack6_1.Sku_Type, colpack6_1.Retail, colpack6_1.BAM_OnHand, colpack6_1.InTransit, colpack6_1.BAM_OnOrder, 
                      colpack6_1.Warehouse_OnHand, colpack6_1.ReturnCenter_OnHand, colpack6_1.Qty_OnOrder, colpack6_1.Qty_OnBackorder, colpack6_1.Status, 
                      colpack6_1.IDate, colpack6_1.Store_Min, colpack6_1.Case_Qty, colpack6_1.week1, colpack6_1.week2, colpack6_1.week3, colpack6_1.week4, 
                      colpack6_1.week5, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week7, colpack6_1.week6
FROM         Tmp_Load.dbo.colpack6 AS colpack6_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack6_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 42))
GROUP BY colpack6_1.Dept, colpack6_1.Class, colpack6_1.Sku_Number, colpack6_1.ISBN, colpack6_1.Title, colpack6_1.Author, colpack6_1.Pub_Code, 
                      colpack6_1.Sku_Type, colpack6_1.Retail, colpack6_1.BAM_OnHand, colpack6_1.InTransit, colpack6_1.BAM_OnOrder, 
                      colpack6_1.Warehouse_OnHand, colpack6_1.ReturnCenter_OnHand, colpack6_1.Qty_OnOrder, colpack6_1.Qty_OnBackorder, colpack6_1.Status, 
                      colpack6_1.IDate, colpack6_1.Store_Min, colpack6_1.Case_Qty, colpack6_1.week1, colpack6_1.week2, colpack6_1.week3, colpack6_1.week5, 
                      colpack6_1.week4, colpack6_1.week6
----------------------------------------------------

TRUNCATE TABLE Tmp_Load.dbo.colpack8

INSERT INTO Tmp_Load.dbo.colpack8
SELECT     colpack7_1.Dept, colpack7_1.Class, colpack7_1.Sku_Number, colpack7_1.ISBN, colpack7_1.Title, colpack7_1.Author, colpack7_1.Pub_Code, 
                      colpack7_1.Sku_Type, colpack7_1.Retail, colpack7_1.BAM_OnHand, colpack7_1.InTransit, colpack7_1.BAM_OnOrder, 
                      colpack7_1.Warehouse_OnHand, colpack7_1.ReturnCenter_OnHand, colpack7_1.Qty_OnOrder, colpack7_1.Qty_OnBackorder, colpack7_1.Status, 
                      colpack7_1.IDate, colpack7_1.Store_Min, colpack7_1.Case_Qty, colpack7_1.week1, colpack7_1.week2, colpack7_1.week3, colpack7_1.week4, 
                      colpack7_1.week5, colpack7_1.week6, colpack7_1.week7, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week8
FROM         Tmp_Load.dbo.colpack7 AS colpack7_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack7_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 49))
GROUP BY colpack7_1.Dept, colpack7_1.Class, colpack7_1.Sku_Number, colpack7_1.ISBN, colpack7_1.Title, colpack7_1.Author, colpack7_1.Pub_Code, 
                      colpack7_1.Sku_Type, colpack7_1.Retail, colpack7_1.BAM_OnHand, colpack7_1.InTransit, colpack7_1.BAM_OnOrder, 
                      colpack7_1.Warehouse_OnHand, colpack7_1.ReturnCenter_OnHand, colpack7_1.Qty_OnOrder, colpack7_1.Qty_OnBackorder, colpack7_1.Status, 
                      colpack7_1.IDate, colpack7_1.Store_Min, colpack7_1.Case_Qty, colpack7_1.week1, colpack7_1.week2, colpack7_1.week3, colpack7_1.week5, 
                      colpack7_1.week4, colpack7_1.week6, colpack7_1.week7
------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack9
INSERT INTO Tmp_Load.dbo.colpack9
SELECT     colpack8_1.Dept, colpack8_1.Class, colpack8_1.Sku_Number, colpack8_1.ISBN, colpack8_1.Title, colpack8_1.Author, colpack8_1.Pub_Code, 
                      colpack8_1.Sku_Type, colpack8_1.Retail, colpack8_1.BAM_OnHand, colpack8_1.InTransit, colpack8_1.BAM_OnOrder, 
                      colpack8_1.Warehouse_OnHand, colpack8_1.ReturnCenter_OnHand, colpack8_1.Qty_OnOrder, colpack8_1.Qty_OnBackorder, colpack8_1.Status, 
                      colpack8_1.IDate, colpack8_1.Store_Min, colpack8_1.Case_Qty, colpack8_1.week1, colpack8_1.week2, colpack8_1.week3, colpack8_1.week4, 
                      colpack8_1.week5, colpack8_1.week6, colpack8_1.week7, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week8
FROM         Tmp_Load.dbo.colpack8 AS colpack8_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack8_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 56))
GROUP BY colpack8_1.Dept, colpack8_1.Class, colpack8_1.Sku_Number, colpack8_1.ISBN, colpack8_1.Title, colpack8_1.Author, colpack8_1.Pub_Code, 
                      colpack8_1.Sku_Type, colpack8_1.Retail, colpack8_1.BAM_OnHand, colpack8_1.InTransit, colpack8_1.BAM_OnOrder, 
                      colpack8_1.Warehouse_OnHand, colpack8_1.ReturnCenter_OnHand, colpack8_1.Qty_OnOrder, colpack8_1.Qty_OnBackorder, colpack8_1.Status, 
                      colpack8_1.IDate, colpack8_1.Store_Min, colpack8_1.Case_Qty, colpack8_1.week1, colpack8_1.week2, colpack8_1.week3, colpack8_1.week5, 
                      colpack8_1.week4, colpack8_1.week6, colpack8_1.week7
---------------------------------------------------------------------------

TRUNCATE TABLE Tmp_Load.dbo.colpack10
INSERT INTO Tmp_Load.dbo.colpack10

SELECT     colpack9_1.Dept, colpack9_1.Class, colpack9_1.Sku_Number, colpack9_1.ISBN, colpack9_1.Title, colpack9_1.Author, colpack9_1.Pub_Code, 
                      colpack9_1.Sku_Type, colpack9_1.Retail, colpack9_1.BAM_OnHand, colpack9_1.InTransit, colpack9_1.BAM_OnOrder, 
                      colpack9_1.Warehouse_OnHand, colpack9_1.ReturnCenter_OnHand, colpack9_1.Qty_OnOrder, colpack9_1.Qty_OnBackorder, colpack9_1.Status, 
                      colpack9_1.IDate, colpack9_1.Store_Min, colpack9_1.Case_Qty, colpack9_1.week1, colpack9_1.week2, colpack9_1.week3, colpack9_1.week4, 
                      colpack9_1.week5, colpack9_1.week6, colpack9_1.week7, colpack9_1.week8, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week9
FROM         Tmp_Load.dbo.colpack9 AS colpack9_1 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack9_1.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 63))
GROUP BY colpack9_1.Dept, colpack9_1.Class, colpack9_1.Sku_Number, colpack9_1.ISBN, colpack9_1.Title, colpack9_1.Author, colpack9_1.Pub_Code, 
                      colpack9_1.Sku_Type, colpack9_1.Retail, colpack9_1.BAM_OnHand, colpack9_1.InTransit, colpack9_1.BAM_OnOrder, 
                      colpack9_1.Warehouse_OnHand, colpack9_1.ReturnCenter_OnHand, colpack9_1.Qty_OnOrder, colpack9_1.Qty_OnBackorder, colpack9_1.Status, 
                      colpack9_1.IDate, colpack9_1.Store_Min, colpack9_1.Case_Qty, colpack9_1.week1, colpack9_1.week2, colpack9_1.week3, colpack9_1.week5, 
                      colpack9_1.week4, colpack9_1.week6, colpack9_1.week7, colpack9_1.week8
----------------------------------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack11
INSERT INTO Tmp_Load.dbo.colpack11
SELECT     colpack10.Dept, colpack10.Class, colpack10.Sku_Number, colpack10.ISBN, colpack10.Title, colpack10.Author, colpack10.Pub_Code, 
                      colpack10.Sku_Type, colpack10.Retail, colpack10.BAM_OnHand, colpack10.InTransit, colpack10.BAM_OnOrder, colpack10.Warehouse_OnHand, 
                      colpack10.ReturnCenter_OnHand, colpack10.Qty_OnOrder, colpack10.Qty_OnBackorder, colpack10.Status, colpack10.IDate, colpack10.Store_Min, 
                      colpack10.Case_Qty, colpack10.week1, colpack10.week2, colpack10.week3, colpack10.week4, colpack10.week5, colpack10.week6, colpack10.week7, 
                      colpack10.week8, colpack10.week9, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week10
FROM         Tmp_Load.dbo.colpack10 AS colpack10 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack10.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 70))
GROUP BY colpack10.Dept, colpack10.Class, colpack10.Sku_Number, colpack10.ISBN, colpack10.Title, colpack10.Author, colpack10.Pub_Code, 
                      colpack10.Sku_Type, colpack10.Retail, colpack10.BAM_OnHand, colpack10.InTransit, colpack10.BAM_OnOrder, colpack10.Warehouse_OnHand, 
                      colpack10.ReturnCenter_OnHand, colpack10.Qty_OnOrder, colpack10.Qty_OnBackorder, colpack10.Status, colpack10.IDate, colpack10.Store_Min, 
                      colpack10.Case_Qty, colpack10.week1, colpack10.week2, colpack10.week3, colpack10.week5, colpack10.week4, colpack10.week6, colpack10.week7, 
                      colpack10.week8, colpack10.week9

------------------------------------------------------------------------------------

TRUNCATE TABLE Tmp_Load.dbo.colpack12
INSERT INTO Tmp_Load.dbo.colpack12
SELECT     colpack11.Dept, colpack11.Class, colpack11.Sku_Number, colpack11.ISBN, colpack11.Title, colpack11.Author, colpack11.Pub_Code, 
                      colpack11.Sku_Type, colpack11.Retail, colpack11.BAM_OnHand, colpack11.InTransit, colpack11.BAM_OnOrder, colpack11.Warehouse_OnHand, 
                      colpack11.ReturnCenter_OnHand, colpack11.Qty_OnOrder, colpack11.Qty_OnBackorder, colpack11.Status, colpack11.IDate, colpack11.Store_Min, 
                      colpack11.Case_Qty, colpack11.week1, colpack11.week2, colpack11.week3, colpack11.week4, colpack11.week5, colpack11.week6, colpack11.week7, 
                      colpack11.week8, colpack11.week9, colpack11.week10, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week11
FROM         Tmp_Load.dbo.colpack11 AS colpack11 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack11.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 77))
GROUP BY colpack11.Dept, colpack11.Class, colpack11.Sku_Number, colpack11.ISBN, colpack11.Title, colpack11.Author, colpack11.Pub_Code, 
                      colpack11.Sku_Type, colpack11.Retail, colpack11.BAM_OnHand, colpack11.InTransit, colpack11.BAM_OnOrder, colpack11.Warehouse_OnHand, 
                      colpack11.ReturnCenter_OnHand, colpack11.Qty_OnOrder, colpack11.Qty_OnBackorder, colpack11.Status, colpack11.IDate, colpack11.Store_Min, 
                      colpack11.Case_Qty, colpack11.week1, colpack11.week2, colpack11.week3, colpack11.week5, colpack11.week4, colpack11.week6, colpack11.week7, 
                      colpack11.week8, colpack11.week9, colpack11.week10
------------------------------------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack13
INSERT INTO Tmp_Load.dbo.colpack13
SELECT     colpack12.Dept, colpack12.Class, colpack12.Sku_Number, colpack12.ISBN, colpack12.Title, colpack12.Author, colpack12.Pub_Code, 
                      colpack12.Sku_Type, colpack12.Retail, colpack12.BAM_OnHand, colpack12.InTransit, colpack12.BAM_OnOrder, colpack12.Warehouse_OnHand, 
                      colpack12.ReturnCenter_OnHand, colpack12.Qty_OnOrder, colpack12.Qty_OnBackorder, colpack12.Status, colpack12.IDate, colpack12.Store_Min, 
                      colpack12.Case_Qty, colpack12.week1, colpack12.week2, colpack12.week3, colpack12.week4, colpack12.week5, colpack12.week6, colpack12.week7, 
                      colpack12.week8, colpack12.week9, colpack12.week10, colpack12.week11, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS week12
FROM         Tmp_Load.dbo.COLPACK12 AS colpack12 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack12.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 84))
GROUP BY colpack12.Dept, colpack12.Class, colpack12.Sku_Number, colpack12.ISBN, colpack12.Title, colpack12.Author, colpack12.Pub_Code, 
                      colpack12.Sku_Type, colpack12.Retail, colpack12.BAM_OnHand, colpack12.InTransit, colpack12.BAM_OnOrder, colpack12.Warehouse_OnHand, 
                      colpack12.ReturnCenter_OnHand, colpack12.Qty_OnOrder, colpack12.Qty_OnBackorder, colpack12.Status, colpack12.IDate, colpack12.Store_Min, 
                      colpack12.Case_Qty, colpack12.week1, colpack12.week2, colpack12.week3, colpack12.week5, colpack12.week4, colpack12.week6, colpack12.week7, 
                      colpack12.week8, colpack12.week9, colpack12.week10, colpack12.week11
------------BUILD  WEEK 13--------------------------------------------------------

TRUNCATE TABLE Tmp_Load.dbo.colpack14
INSERT INTO Tmp_Load.dbo.colpack14
SELECT     colpack13.Dept, colpack13.Class, colpack13.Sku_Number, colpack13.ISBN, colpack13.Title, colpack13.Author, colpack13.Pub_Code, 
                      colpack13.Sku_Type, colpack13.Retail, colpack13.BAM_OnHand, colpack13.InTransit, colpack13.BAM_OnOrder, colpack13.Warehouse_OnHand, 
                      colpack13.ReturnCenter_OnHand, colpack13.Qty_OnOrder, colpack13.Qty_OnBackorder, colpack13.Status, colpack13.IDate, colpack13.Store_Min, 
                      colpack13.Case_Qty, colpack13.week1, colpack13.week2, colpack13.week3, colpack13.week4, colpack13.week5, colpack13.week6, colpack13.week7, 
                      colpack13.week8, colpack13.week9, colpack13.week10, colpack13.week11, colpack13.week12, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS week13
FROM         Tmp_Load.dbo.colpack13 AS colpack13 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack13.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 91))
GROUP BY colpack13.Dept, colpack13.Class, colpack13.Sku_Number, colpack13.ISBN, colpack13.Title, colpack13.Author, colpack13.Pub_Code, 
                      colpack13.Sku_Type, colpack13.Retail, colpack13.BAM_OnHand, colpack13.InTransit, colpack13.BAM_OnOrder, colpack13.Warehouse_OnHand, 
                      colpack13.ReturnCenter_OnHand, colpack13.Qty_OnOrder, colpack13.Qty_OnBackorder, colpack13.Status, colpack13.IDate, colpack13.Store_Min, 
                      colpack13.Case_Qty, colpack13.week1, colpack13.week2, colpack13.week3, colpack13.week5, colpack13.week4, colpack13.week6, colpack13.week7, 
                      colpack13.week8, colpack13.week9, colpack13.week10, colpack13.week11, colpack13.week12

-----------------------------------------------------------------------------------------------
---BUILD LAST YEARS 13 WEEKS ------------------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack15
INSERT INTO Tmp_Load.dbo.colpack15
SELECT     colpack14.Dept, colpack14.Class, colpack14.Sku_Number, colpack14.ISBN, colpack14.Title, colpack14.Author, colpack14.Pub_Code, 
                      colpack14.Sku_Type, colpack14.Retail, colpack14.BAM_OnHand, colpack14.InTransit, colpack14.BAM_OnOrder, colpack14.Warehouse_OnHand, 
                      colpack14.ReturnCenter_OnHand, colpack14.Qty_OnOrder, colpack14.Qty_OnBackorder, colpack14.Status, colpack14.IDate, colpack14.Store_Min, 
                      colpack14.Case_Qty, colpack14.week1, colpack14.week2, colpack14.week3, colpack14.week4, colpack14.week5, colpack14.week6, colpack14.week7, 
                      colpack14.week8, colpack14.week9, colpack14.week10, colpack14.week11, colpack14.week12, colpack14.week13, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk1
FROM         Tmp_Load.dbo.colpack14 AS colpack14 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack14.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 365))
GROUP BY colpack14.Dept, colpack14.Class, colpack14.Sku_Number, colpack14.ISBN, colpack14.Title, colpack14.Author, colpack14.Pub_Code, 
                      colpack14.Sku_Type, colpack14.Retail, colpack14.BAM_OnHand, colpack14.InTransit, colpack14.BAM_OnOrder, colpack14.Warehouse_OnHand, 
                      colpack14.ReturnCenter_OnHand, colpack14.Qty_OnOrder, colpack14.Qty_OnBackorder, colpack14.Status, colpack14.IDate, colpack14.Store_Min, 
                      colpack14.Case_Qty, colpack14.week1, colpack14.week2, colpack14.week3, colpack14.week5, colpack14.week4, colpack14.week6, colpack14.week7, 
                      colpack14.week8, colpack14.week9, colpack14.week10, colpack14.week11, colpack14.week12, colpack14.week13

---------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack16
INSERT INTO Tmp_Load.dbo.colpack16
SELECT     colpack15.Dept, colpack15.Class, colpack15.Sku_Number, colpack15.ISBN, colpack15.Title, colpack15.Author, colpack15.Pub_Code, 
                      colpack15.Sku_Type, colpack15.Retail, colpack15.BAM_OnHand, colpack15.InTransit, colpack15.BAM_OnOrder, colpack15.Warehouse_OnHand, 
                      colpack15.ReturnCenter_OnHand, colpack15.Qty_OnOrder, colpack15.Qty_OnBackorder, colpack15.Status, colpack15.IDate, colpack15.Store_Min, 
                      colpack15.Case_Qty, colpack15.week1, colpack15.week2, colpack15.week3, colpack15.week4, colpack15.week5, colpack15.week6, colpack15.week7, 
                      colpack15.week8, colpack15.week9, colpack15.week10, colpack15.week11, colpack15.week12, colpack15.week13, colpack15.LyWk1, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk2
FROM         Tmp_Load.dbo.colpack15 AS colpack15 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack15.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 358))
GROUP BY colpack15.Dept, colpack15.Class, colpack15.Sku_Number, colpack15.ISBN, colpack15.Title, colpack15.Author, colpack15.Pub_Code, 
                      colpack15.Sku_Type, colpack15.Retail, colpack15.BAM_OnHand, colpack15.InTransit, colpack15.BAM_OnOrder, colpack15.Warehouse_OnHand, 
                      colpack15.ReturnCenter_OnHand, colpack15.Qty_OnOrder, colpack15.Qty_OnBackorder, colpack15.Status, colpack15.IDate, colpack15.Store_Min, 
                      colpack15.Case_Qty, colpack15.week1, colpack15.week2, colpack15.week3, colpack15.week5, colpack15.week4, colpack15.week6, colpack15.week7, 
                      colpack15.week8, colpack15.week9, colpack15.week10, colpack15.week11, colpack15.week12, colpack15.week13, colpack15.LyWk1

---------------build ly wk3-------------------------
TRUNCATE TABLE  Tmp_Load.dbo.colpack17
INSERT  INTO Tmp_Load.dbo.colpack17
SELECT     colpack16.Dept, colpack16.Class, colpack16.Sku_Number, colpack16.ISBN, colpack16.Title, colpack16.Author, colpack16.Pub_Code, 
                      colpack16.Sku_Type, colpack16.Retail, colpack16.BAM_OnHand, colpack16.InTransit, colpack16.BAM_OnOrder, colpack16.Warehouse_OnHand, 
                      colpack16.ReturnCenter_OnHand, colpack16.Qty_OnOrder, colpack16.Qty_OnBackorder, colpack16.Status, colpack16.IDate, colpack16.Store_Min, 
                      colpack16.Case_Qty, colpack16.week1, colpack16.week2, colpack16.week3, colpack16.week4, colpack16.week5, colpack16.week6, colpack16.week7, 
                      colpack16.week8, colpack16.week9, colpack16.week10, colpack16.week11, colpack16.week12, colpack16.week13, colpack16.LyWk1, colpack16.LyWk2, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk3
FROM         Tmp_Load.dbo.colpack16 AS colpack16 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack16.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 351))
GROUP BY colpack16.Dept, colpack16.Class, colpack16.Sku_Number, colpack16.ISBN, colpack16.Title, colpack16.Author, colpack16.Pub_Code, 
                      colpack16.Sku_Type, colpack16.Retail, colpack16.BAM_OnHand, colpack16.InTransit, colpack16.BAM_OnOrder, colpack16.Warehouse_OnHand, 
                      colpack16.ReturnCenter_OnHand, colpack16.Qty_OnOrder, colpack16.Qty_OnBackorder, colpack16.Status, colpack16.IDate, colpack16.Store_Min, 
                      colpack16.Case_Qty, colpack16.week1, colpack16.week2, colpack16.week3, colpack16.week5, colpack16.week4, colpack16.week6, colpack16.week7, 
                      colpack16.week8, colpack16.week9, colpack16.week10, colpack16.week11, colpack16.week12, colpack16.week13, colpack16.LyWk1, colpack16.LyWk2
------------------------------build ly wk4------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack18
INSERT INTO Tmp_Load.dbo.colpack18
SELECT     colpack17.Dept, colpack17.Class, colpack17.Sku_Number, colpack17.ISBN, colpack17.Title, colpack17.Author, colpack17.Pub_Code, 
                      colpack17.Sku_Type, colpack17.Retail, colpack17.BAM_OnHand, colpack17.InTransit, colpack17.BAM_OnOrder, colpack17.Warehouse_OnHand, 
                      colpack17.ReturnCenter_OnHand, colpack17.Qty_OnOrder, colpack17.Qty_OnBackorder, colpack17.Status, colpack17.IDate, colpack17.Store_Min, 
                      colpack17.Case_Qty, colpack17.week1, colpack17.week2, colpack17.week3, colpack17.week4, colpack17.week5, colpack17.week6, colpack17.week7, 
                      colpack17.week8, colpack17.week9, colpack17.week10, colpack17.week11, colpack17.week12, colpack17.week13, colpack17.LyWk1, colpack17.LyWk2, 
                      colpack17.LyWk3, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk4
FROM         Tmp_Load.dbo.colpack17 AS colpack17 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack17.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 344))
GROUP BY colpack17.Dept, colpack17.Class, colpack17.Sku_Number, colpack17.ISBN, colpack17.Title, colpack17.Author, colpack17.Pub_Code, 
                      colpack17.Sku_Type, colpack17.Retail, colpack17.BAM_OnHand, colpack17.InTransit, colpack17.BAM_OnOrder, colpack17.Warehouse_OnHand, 
                      colpack17.ReturnCenter_OnHand, colpack17.Qty_OnOrder, colpack17.Qty_OnBackorder, colpack17.Status, colpack17.IDate, colpack17.Store_Min, 
                      colpack17.Case_Qty, colpack17.week1, colpack17.week2, colpack17.week3, colpack17.week5, colpack17.week4, colpack17.week6, colpack17.week7, 
                      colpack17.week8, colpack17.week9, colpack17.week10, colpack17.week11, colpack17.week12, colpack17.week13, colpack17.LyWk1, colpack17.LyWk2, 
                      colpack17.LyWk3
----------------------build lywk5-----------------------------------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack19
INSERT INTO Tmp_Load.dbo.colpack19
SELECT     colpack18.Dept, colpack18.Class, colpack18.Sku_Number, colpack18.ISBN, colpack18.Title, colpack18.Author, colpack18.Pub_Code, 
                      colpack18.Sku_Type, colpack18.Retail, colpack18.BAM_OnHand, colpack18.InTransit, colpack18.BAM_OnOrder, colpack18.Warehouse_OnHand, 
                      colpack18.ReturnCenter_OnHand, colpack18.Qty_OnOrder, colpack18.Qty_OnBackorder, colpack18.Status, colpack18.IDate, colpack18.Store_Min, 
                      colpack18.Case_Qty, colpack18.week1, colpack18.week2, colpack18.week3, colpack18.week4, colpack18.week5, colpack18.week6, colpack18.week7, 
                      colpack18.week8, colpack18.week9, colpack18.week10, colpack18.week11, colpack18.week12, colpack18.week13, colpack18.LyWk1, colpack18.LyWk2, 
                      colpack18.LyWk3, colpack18.LyWk4, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk5
FROM         Tmp_Load.dbo.colpack18 AS colpack18 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack18.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 337))
GROUP BY colpack18.Dept, colpack18.Class, colpack18.Sku_Number, colpack18.ISBN, colpack18.Title, colpack18.Author, colpack18.Pub_Code, 
                      colpack18.Sku_Type, colpack18.Retail, colpack18.BAM_OnHand, colpack18.InTransit, colpack18.BAM_OnOrder, colpack18.Warehouse_OnHand, 
                      colpack18.ReturnCenter_OnHand, colpack18.Qty_OnOrder, colpack18.Qty_OnBackorder, colpack18.Status, colpack18.IDate, colpack18.Store_Min, 
                      colpack18.Case_Qty, colpack18.week1, colpack18.week2, colpack18.week3, colpack18.week5, colpack18.week4, colpack18.week6, colpack18.week7, 
                      colpack18.week8, colpack18.week9, colpack18.week10, colpack18.week11, colpack18.week12, colpack18.week13, colpack18.LyWk1, colpack18.LyWk2, 
                      colpack18.LyWk3, colpack18.LyWk4

------------------build lywk6-------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack20
INSERT INTO Tmp_Load.dbo.colpack20
SELECT     colpack19.Dept, colpack19.Class, colpack19.Sku_Number, colpack19.ISBN, colpack19.Title, colpack19.Author, colpack19.Pub_Code, 
                      colpack19.Sku_Type, colpack19.Retail, colpack19.BAM_OnHand, colpack19.InTransit, colpack19.BAM_OnOrder, colpack19.Warehouse_OnHand, 
                      colpack19.ReturnCenter_OnHand, colpack19.Qty_OnOrder, colpack19.Qty_OnBackorder, colpack19.Status, colpack19.IDate, colpack19.Store_Min, 
                      colpack19.Case_Qty, colpack19.week1, colpack19.week2, colpack19.week3, colpack19.week4, colpack19.week5, colpack19.week6, colpack19.week7, 
                      colpack19.week8, colpack19.week9, colpack19.week10, colpack19.week11, colpack19.week12, colpack19.week13, colpack19.LyWk1, colpack19.LyWk2, 
                      colpack19.LyWk3, colpack19.LyWk4, colpack19.LyWk5, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk6

FROM         Tmp_Load.dbo.colpack19 AS colpack19 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack19.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 330))
GROUP BY colpack19.Dept, colpack19.Class, colpack19.Sku_Number, colpack19.ISBN, colpack19.Title, colpack19.Author, colpack19.Pub_Code, 
                      colpack19.Sku_Type, colpack19.Retail, colpack19.BAM_OnHand, colpack19.InTransit, colpack19.BAM_OnOrder, colpack19.Warehouse_OnHand, 
                      colpack19.ReturnCenter_OnHand, colpack19.Qty_OnOrder, colpack19.Qty_OnBackorder, colpack19.Status, colpack19.IDate, colpack19.Store_Min, 
                      colpack19.Case_Qty, colpack19.week1, colpack19.week2, colpack19.week3, colpack19.week5, colpack19.week4, colpack19.week6, colpack19.week7, 
                      colpack19.week8, colpack19.week9, colpack19.week10, colpack19.week11, colpack19.week12, colpack19.week13, colpack19.LyWk1, colpack19.LyWk2, 
                      colpack19.LyWk3, colpack19.LyWk4, colpack19.LyWk5
-------------------build lywk7----------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack21
INSERT INTO Tmp_Load.dbo.colpack21
SELECT     colpack20.Dept, colpack20.Class, colpack20.Sku_Number, colpack20.ISBN, colpack20.Title, colpack20.Author, colpack20.Pub_Code, 
                      colpack20.Sku_Type, colpack20.Retail, colpack20.BAM_OnHand, colpack20.InTransit, colpack20.BAM_OnOrder, colpack20.Warehouse_OnHand, 
                      colpack20.ReturnCenter_OnHand, colpack20.Qty_OnOrder, colpack20.Qty_OnBackorder, colpack20.Status, colpack20.IDate, colpack20.Store_Min, 
                      colpack20.Case_Qty, colpack20.week1, colpack20.week2, colpack20.week3, colpack20.week4, colpack20.week5, colpack20.week6, colpack20.week7, 
                      colpack20.week8, colpack20.week9, colpack20.week10, colpack20.week11, colpack20.week12, colpack20.week13, colpack20.LyWk1, colpack20.LyWk2, 
                      colpack20.LyWk3, colpack20.LyWk4, colpack20.LyWk5, colpack20.LyWk6, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk7
FROM         Tmp_Load.dbo.colpack20 AS colpack20 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack20.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 323))
GROUP BY colpack20.Dept, colpack20.Class, colpack20.Sku_Number, colpack20.ISBN, colpack20.Title, colpack20.Author, colpack20.Pub_Code, 
                      colpack20.Sku_Type, colpack20.Retail, colpack20.BAM_OnHand, colpack20.InTransit, colpack20.BAM_OnOrder, colpack20.Warehouse_OnHand, 
                      colpack20.ReturnCenter_OnHand, colpack20.Qty_OnOrder, colpack20.Qty_OnBackorder, colpack20.Status, colpack20.IDate, colpack20.Store_Min, 
                      colpack20.Case_Qty, colpack20.week1, colpack20.week2, colpack20.week3, colpack20.week5, colpack20.week4, colpack20.week6, colpack20.week7, 
                      colpack20.week8, colpack20.week9, colpack20.week10, colpack20.week11, colpack20.week12, colpack20.week13, colpack20.LyWk1, colpack20.LyWk2, 
                      colpack20.LyWk3, colpack20.LyWk4, colpack20.LyWk5, colpack20.LyWk6
-------------build lywk8-------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack22
INSERT INTO Tmp_Load.dbo.colpack22
SELECT     colpack21.Dept, colpack21.Class, colpack21.Sku_Number, colpack21.ISBN, colpack21.Title, colpack21.Author, colpack21.Pub_Code, 
                      colpack21.Sku_Type, colpack21.Retail, colpack21.BAM_OnHand, colpack21.InTransit, colpack21.BAM_OnOrder, colpack21.Warehouse_OnHand, 
                      colpack21.ReturnCenter_OnHand, colpack21.Qty_OnOrder, colpack21.Qty_OnBackorder, colpack21.Status, colpack21.IDate, colpack21.Store_Min, 
                      colpack21.Case_Qty, colpack21.week1, colpack21.week2, colpack21.week3, colpack21.week4, colpack21.week5, colpack21.week6, colpack21.week7, 
                      colpack21.week8, colpack21.week9, colpack21.week10, colpack21.week11, colpack21.week12, colpack21.week13, colpack21.LyWk1, colpack21.LyWk2, 
                      colpack21.LyWk3, colpack21.LyWk4, colpack21.LyWk5, colpack21.LyWk6, colpack21.LyWk7, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS LyWk8
FROM         Tmp_Load.dbo.colpack21 AS colpack21 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack21.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 316))
GROUP BY colpack21.Dept, colpack21.Class, colpack21.Sku_Number, colpack21.ISBN, colpack21.Title, colpack21.Author, colpack21.Pub_Code, 
                      colpack21.Sku_Type, colpack21.Retail, colpack21.BAM_OnHand, colpack21.InTransit, colpack21.BAM_OnOrder, colpack21.Warehouse_OnHand, 
                      colpack21.ReturnCenter_OnHand, colpack21.Qty_OnOrder, colpack21.Qty_OnBackorder, colpack21.Status, colpack21.IDate, colpack21.Store_Min, 
                      colpack21.Case_Qty, colpack21.week1, colpack21.week2, colpack21.week3, colpack21.week5, colpack21.week4, colpack21.week6, colpack21.week7, 
                      colpack21.week8, colpack21.week9, colpack21.week10, colpack21.week11, colpack21.week12, colpack21.week13, colpack21.LyWk1, colpack21.LyWk2, 
                      colpack21.LyWk3, colpack21.LyWk4, colpack21.LyWk5, colpack21.LyWk6, colpack21.LyWk7
--------------build lywk9----------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack23
INSERT INTO Tmp_Load.dbo.colpack23
SELECT     colpack22.Dept, colpack22.Class, colpack22.Sku_Number, colpack22.ISBN, colpack22.Title, colpack22.Author, colpack22.Pub_Code, 
                      colpack22.Sku_Type, colpack22.Retail, colpack22.BAM_OnHand, colpack22.InTransit, colpack22.BAM_OnOrder, colpack22.Warehouse_OnHand, 
                      colpack22.ReturnCenter_OnHand, colpack22.Qty_OnOrder, colpack22.Qty_OnBackorder, colpack22.Status, colpack22.IDate, colpack22.Store_Min, 
                      colpack22.Case_Qty, colpack22.week1, colpack22.week2, colpack22.week3, colpack22.week4, colpack22.week5, colpack22.week6, colpack22.week7, 
                      colpack22.week8, colpack22.week9, colpack22.week10, colpack22.week11, colpack22.week12, colpack22.week13, colpack22.LyWk1, colpack22.LyWk2, 
                      colpack22.LyWk3, colpack22.LyWk4, colpack22.LyWk5, colpack22.LyWk6, colpack22.LyWk7, colpack22.LyWk8, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk9
FROM         Tmp_Load.dbo.colpack22 AS colpack22 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack22.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 309))
GROUP BY colpack22.Dept, colpack22.Class, colpack22.Sku_Number, colpack22.ISBN, colpack22.Title, colpack22.Author, colpack22.Pub_Code, 
                      colpack22.Sku_Type, colpack22.Retail, colpack22.BAM_OnHand, colpack22.InTransit, colpack22.BAM_OnOrder, colpack22.Warehouse_OnHand, 
                      colpack22.ReturnCenter_OnHand, colpack22.Qty_OnOrder, colpack22.Qty_OnBackorder, colpack22.Status, colpack22.IDate, colpack22.Store_Min, 
                      colpack22.Case_Qty, colpack22.week1, colpack22.week2, colpack22.week3, colpack22.week5, colpack22.week4, colpack22.week6, colpack22.week7, 
                      colpack22.week8, colpack22.week9, colpack22.week10, colpack22.week11, colpack22.week12, colpack22.week13, colpack22.LyWk1, colpack22.LyWk2, 
                      colpack22.LyWk3, colpack22.LyWk4, colpack22.LyWk5, colpack22.LyWk6, colpack22.LyWk7, colpack22.LyWk8

----------------build lywk10--------------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack24
INSERT INTO Tmp_Load.dbo.colpack24
SELECT     colpack23.Dept, colpack23.Class, colpack23.Sku_Number, colpack23.ISBN, colpack23.Title, colpack23.Author, colpack23.Pub_Code, 
                      colpack23.Sku_Type, colpack23.Retail, colpack23.BAM_OnHand, colpack23.InTransit, colpack23.BAM_OnOrder, colpack23.Warehouse_OnHand, 
                      colpack23.ReturnCenter_OnHand, colpack23.Qty_OnOrder, colpack23.Qty_OnBackorder, colpack23.Status, colpack23.IDate, colpack23.Store_Min, 
                      colpack23.Case_Qty, colpack23.week1, colpack23.week2, colpack23.week3, colpack23.week4, colpack23.week5, colpack23.week6, colpack23.week7, 
                      colpack23.week8, colpack23.week9, colpack23.week10, colpack23.week11, colpack23.week12, colpack23.week13, colpack23.LyWk1, colpack23.LyWk2, 
                      colpack23.LyWk3, colpack23.LyWk4, colpack23.LyWk5, colpack23.LyWk6, colpack23.LyWk7, colpack23.LyWk8, colpack23.LyWk9, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk10
FROM         Tmp_Load.dbo.colpack23 AS colpack23 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack23.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 302))
GROUP BY colpack23.Dept, colpack23.Class, colpack23.Sku_Number, colpack23.ISBN, colpack23.Title, colpack23.Author, colpack23.Pub_Code, 
                      colpack23.Sku_Type, colpack23.Retail, colpack23.BAM_OnHand, colpack23.InTransit, colpack23.BAM_OnOrder, colpack23.Warehouse_OnHand, 
                      colpack23.ReturnCenter_OnHand, colpack23.Qty_OnOrder, colpack23.Qty_OnBackorder, colpack23.Status, colpack23.IDate, colpack23.Store_Min, 
                      colpack23.Case_Qty, colpack23.week1, colpack23.week2, colpack23.week3, colpack23.week5, colpack23.week4, colpack23.week6, colpack23.week7, 
                      colpack23.week8, colpack23.week9, colpack23.week10, colpack23.week11, colpack23.week12, colpack23.week13, colpack23.LyWk1, colpack23.LyWk2, 
                      colpack23.LyWk3, colpack23.LyWk4, colpack23.LyWk5, colpack23.LyWk6, colpack23.LyWk7, colpack23.LyWk8, colpack23.LyWk9

------------------build lywk11------------------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack25
INSERT INTO Tmp_Load.dbo.colpack25
SELECT     colpack24.Dept, colpack24.Class, colpack24.Sku_Number, colpack24.ISBN, colpack24.Title, colpack24.Author, colpack24.Pub_Code, 
                      colpack24.Sku_Type, colpack24.Retail, colpack24.BAM_OnHand, colpack24.InTransit, colpack24.BAM_OnOrder, colpack24.Warehouse_OnHand, 
                      colpack24.ReturnCenter_OnHand, colpack24.Qty_OnOrder, colpack24.Qty_OnBackorder, colpack24.Status, colpack24.IDate, colpack24.Store_Min, 
                      colpack24.Case_Qty, colpack24.week1, colpack24.week2, colpack24.week3, colpack24.week4, colpack24.week5, colpack24.week6, colpack24.week7, 
                      colpack24.week8, colpack24.week9, colpack24.week10, colpack24.week11, colpack24.week12, colpack24.week13, colpack24.LyWk1, colpack24.LyWk2, 
                      colpack24.LyWk3, colpack24.LyWk4, colpack24.LyWk5, colpack24.LyWk6, colpack24.LyWk7, colpack24.LyWk8, colpack24.LyWk9, colpack24.LyWk10, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk11
FROM         Tmp_Load.dbo.colpack24 AS colpack24 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack24.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 295))
GROUP BY colpack24.Dept, colpack24.Class, colpack24.Sku_Number, colpack24.ISBN, colpack24.Title, colpack24.Author, colpack24.Pub_Code, 
                      colpack24.Sku_Type, colpack24.Retail, colpack24.BAM_OnHand, colpack24.InTransit, colpack24.BAM_OnOrder, colpack24.Warehouse_OnHand, 
                      colpack24.ReturnCenter_OnHand, colpack24.Qty_OnOrder, colpack24.Qty_OnBackorder, colpack24.Status, colpack24.IDate, colpack24.Store_Min, 
                      colpack24.Case_Qty, colpack24.week1, colpack24.week2, colpack24.week3, colpack24.week5, colpack24.week4, colpack24.week6, colpack24.week7, 
                      colpack24.week8, colpack24.week9, colpack24.week10, colpack24.week11, colpack24.week12, colpack24.week13, colpack24.LyWk1, colpack24.LyWk2, 
                      colpack24.LyWk3, colpack24.LyWk4, colpack24.LyWk5, colpack24.LyWk6, colpack24.LyWk7, colpack24.LyWk8, colpack24.LyWk9, colpack24.LyWk10
-------------------build lywk12--------------------
TRUNCATE TABLE Tmp_Load.dbo.colpack26
INSERT INTO Tmp_Load.dbo.colpack26
SELECT     colpack25.Dept, colpack25.Class, colpack25.Sku_Number, colpack25.ISBN, colpack25.Title, colpack25.Author, colpack25.Pub_Code, 
                      colpack25.Sku_Type, colpack25.Retail, colpack25.BAM_OnHand, colpack25.InTransit, colpack25.BAM_OnOrder, colpack25.Warehouse_OnHand, 
                      colpack25.ReturnCenter_OnHand, colpack25.Qty_OnOrder, colpack25.Qty_OnBackorder, colpack25.Status, colpack25.IDate, colpack25.Store_Min, 
                      colpack25.Case_Qty, colpack25.week1, colpack25.week2, colpack25.week3, colpack25.week4, colpack25.week5, colpack25.week6, colpack25.week7, 
                      colpack25.week8, colpack25.week9, colpack25.week10, colpack25.week11, colpack25.week12, colpack25.week13, colpack25.LyWk1, colpack25.LyWk2, 
                      colpack25.LyWk3, colpack25.LyWk4, colpack25.LyWk5, colpack25.LyWk6, colpack25.LyWk7, colpack25.LyWk8, colpack25.LyWk9, colpack25.LyWk10, 
                      colpack25.LyWk11, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk12
FROM         Tmp_Load.dbo.colpack25 AS colpack25 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack25.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 288))
GROUP BY colpack25.Dept, colpack25.Class, colpack25.Sku_Number, colpack25.ISBN, colpack25.Title, colpack25.Author, colpack25.Pub_Code, 
                      colpack25.Sku_Type, colpack25.Retail, colpack25.BAM_OnHand, colpack25.InTransit, colpack25.BAM_OnOrder, colpack25.Warehouse_OnHand, 
                      colpack25.ReturnCenter_OnHand, colpack25.Qty_OnOrder, colpack25.Qty_OnBackorder, colpack25.Status, colpack25.IDate, colpack25.Store_Min, 
                      colpack25.Case_Qty, colpack25.week1, colpack25.week2, colpack25.week3, colpack25.week5, colpack25.week4, colpack25.week6, colpack25.week7, 
                      colpack25.week8, colpack25.week9, colpack25.week10, colpack25.week11, colpack25.week12, colpack25.week13, colpack25.LyWk1, colpack25.LyWk2, 
                      colpack25.LyWk3, colpack25.LyWk4, colpack25.LyWk5, colpack25.LyWk6, colpack25.LyWk7, colpack25.LyWk8, colpack25.LyWk9, colpack25.LyWk10, 
                      colpack25.LyWk11

-----------------build week 13
TRUNCATE TABLE Tmp_Load.dbo.colpack27
INSERT INTO Tmp_Load.dbo.colpack27
SELECT     colpack26.Dept, colpack26.Class, colpack26.Sku_Number, colpack26.ISBN, colpack26.Title, colpack26.Author, colpack26.Pub_Code, 
                      colpack26.Sku_Type, colpack26.Retail, colpack26.BAM_OnHand, colpack26.InTransit, colpack26.BAM_OnOrder, colpack26.Warehouse_OnHand, 
                      colpack26.ReturnCenter_OnHand, colpack26.Qty_OnOrder, colpack26.Qty_OnBackorder, colpack26.Status, colpack26.IDate, colpack26.Store_Min, 
                      colpack26.Case_Qty, colpack26.week1, colpack26.week2, colpack26.week3, colpack26.week4, colpack26.week5, colpack26.week6, colpack26.week7, 
                      colpack26.week8, colpack26.week9, colpack26.week10, colpack26.week11, colpack26.week12, colpack26.week13, colpack26.LyWk1, colpack26.LyWk2, 
                      colpack26.LyWk3, colpack26.LyWk4, colpack26.LyWk5, colpack26.LyWk6, colpack26.LyWk7, colpack26.LyWk8, colpack26.LyWk9, colpack26.LyWk10, 
                      colpack26.LyWk11, colpack26.LyWk12, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk13
FROM         Tmp_Load.dbo.colpack26 AS colpack26 LEFT JOIN
                      DssData.dbo.Weekly_Sales ON colpack26.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 281))
GROUP BY colpack26.Dept, colpack26.Class, colpack26.Sku_Number, colpack26.ISBN, colpack26.Title, colpack26.Author, colpack26.Pub_Code, 
                      colpack26.Sku_Type, colpack26.Retail, colpack26.BAM_OnHand, colpack26.InTransit, colpack26.BAM_OnOrder, colpack26.Warehouse_OnHand, 
                      colpack26.ReturnCenter_OnHand, colpack26.Qty_OnOrder, colpack26.Qty_OnBackorder, colpack26.Status, colpack26.IDate, colpack26.Store_Min, 
                      colpack26.Case_Qty, colpack26.week1, colpack26.week2, colpack26.week3, colpack26.week5, colpack26.week4, colpack26.week6, colpack26.week7, 
                      colpack26.week8, colpack26.week9, colpack26.week10, colpack26.week11, colpack26.week12, colpack26.week13, colpack26.LyWk1, colpack26.LyWk2, 
                      colpack26.LyWk3, colpack26.LyWk4, colpack26.LyWk5, colpack26.LyWk6, colpack26.LyWk7, colpack26.LyWk8, colpack26.LyWk9, colpack26.LyWk10, 
                      colpack26.LyWk11, colpack26.LyWk12

-----------------build week 14
TRUNCATE TABLE Tmp_Load.dbo.colpack28
INSERT INTO Tmp_Load.dbo.colpack28
SELECT     colpack27.Dept, colpack27.Class, colpack27.Sku_Number, colpack27.ISBN, colpack27.Title, colpack27.Author, colpack27.Pub_Code, 
                      colpack27.Sku_Type, colpack27.Retail, colpack27.BAM_OnHand, colpack27.InTransit, colpack27.BAM_OnOrder, colpack27.Warehouse_OnHand, 
                      colpack27.ReturnCenter_OnHand, colpack27.Qty_OnOrder, colpack27.Qty_OnBackorder, colpack27.Status, colpack27.IDate, colpack27.Store_Min, 
                      colpack27.Case_Qty, colpack27.week1, colpack27.week2, colpack27.week3, colpack27.week4, colpack27.week5, colpack27.week6, colpack27.week7, 
                      colpack27.week8, colpack27.week9, colpack27.week10, colpack27.week11, colpack27.week12, colpack27.week13, colpack27.LyWk1, colpack27.LyWk2, 
                      colpack27.LyWk3, colpack27.LyWk4, colpack27.LyWk5, colpack27.LyWk6, colpack27.LyWk7, colpack27.LyWk8, colpack27.LyWk9, colpack27.LyWk10, 
                      colpack27.LyWk11, colpack27.LyWk12, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk13, colpack27.LyWk13 AS [Ly Wk 14]
FROM         colpack27 AS colpack27 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack27.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 274))
GROUP BY colpack27.Dept, colpack27.Class, colpack27.Sku_Number, colpack27.ISBN, colpack27.Title, colpack27.Author, colpack27.Pub_Code, 
                      colpack27.Sku_Type, colpack27.Retail, colpack27.BAM_OnHand, colpack27.InTransit, colpack27.BAM_OnOrder, colpack27.Warehouse_OnHand, 
                      colpack27.ReturnCenter_OnHand, colpack27.Qty_OnOrder, colpack27.Qty_OnBackorder, colpack27.Status, colpack27.IDate, colpack27.Store_Min, 
                      colpack27.Case_Qty, colpack27.week1, colpack27.week2, colpack27.week3, colpack27.week5, colpack27.week4, colpack27.week6, colpack27.week7, 
                      colpack27.week8, colpack27.week9, colpack27.week10, colpack27.week11, colpack27.week12, colpack27.week13, colpack27.LyWk1, colpack27.LyWk2, 
                      colpack27.LyWk3, colpack27.LyWk4, colpack27.LyWk5, colpack27.LyWk6, colpack27.LyWk7, colpack27.LyWk8, colpack27.LyWk9, colpack27.LyWk10, 
                      colpack27.LyWk11, colpack27.LyWk12, colpack27.LyWk13

-----------------build week 15
TRUNCATE TABLE Tmp_Load.dbo.colpack29
INSERT INTO Tmp_Load.dbo.colpack29
SELECT     colpack28.Dept, colpack28.Class, colpack28.Sku_Number, colpack28.ISBN, colpack28.Title, colpack28.Author, colpack28.Pub_Code, 
                      colpack28.Sku_Type, colpack28.Retail, colpack28.BAM_OnHand, colpack28.InTransit, colpack28.BAM_OnOrder, colpack28.Warehouse_OnHand, 
                      colpack28.ReturnCenter_OnHand, colpack28.Qty_OnOrder, colpack28.Qty_OnBackorder, colpack28.Status, colpack28.IDate, colpack28.Store_Min, 
                      colpack28.Case_Qty, colpack28.week1, colpack28.week2, colpack28.week3, colpack28.week4, colpack28.week5, colpack28.week6, colpack28.week7, 
                      colpack28.week8, colpack28.week9, colpack28.week10, colpack28.week11, colpack28.week12, colpack28.week13, colpack28.LyWk1, colpack28.LyWk2, 
                      colpack28.LyWk3, colpack28.LyWk4, colpack28.LyWk5, colpack28.LyWk6, colpack28.LyWk7, colpack28.LyWk8, colpack28.LyWk9, colpack28.LyWk10, 
                      colpack28.LyWk11, colpack28.LyWk12, colpack28.LyWk13, colpack28.[Ly Wk 14], SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk15
FROM         colpack28 AS colpack28 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack28.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 267))
GROUP BY colpack28.Dept, colpack28.Class, colpack28.Sku_Number, colpack28.ISBN, colpack28.Title, colpack28.Author, colpack28.Pub_Code, 
                      colpack28.Sku_Type, colpack28.Retail, colpack28.BAM_OnHand, colpack28.InTransit, colpack28.BAM_OnOrder, colpack28.Warehouse_OnHand, 
                      colpack28.ReturnCenter_OnHand, colpack28.Qty_OnOrder, colpack28.Qty_OnBackorder, colpack28.Status, colpack28.IDate, colpack28.Store_Min, 
                      colpack28.Case_Qty, colpack28.week1, colpack28.week2, colpack28.week3, colpack28.week5, colpack28.week4, colpack28.week6, colpack28.week7, 
                      colpack28.week8, colpack28.week9, colpack28.week10, colpack28.week11, colpack28.week12, colpack28.week13, colpack28.LyWk1, colpack28.LyWk2, 
                      colpack28.LyWk3, colpack28.LyWk4, colpack28.LyWk5, colpack28.LyWk6, colpack28.LyWk7, colpack28.LyWk8, colpack28.LyWk9, colpack28.LyWk10, 
                      colpack28.LyWk11, colpack28.LyWk12, colpack28.LyWk13, colpack28.[Ly Wk 14]

-----------------build week 16
TRUNCATE TABLE Tmp_Load.dbo.colpack30
INSERT INTO Tmp_Load.dbo.colpack30
SELECT     colpack29.Dept, colpack29.Class, colpack29.Sku_Number, colpack29.ISBN, colpack29.Title, colpack29.Author, colpack29.Pub_Code, 
                      colpack29.Sku_Type, colpack29.Retail, colpack29.BAM_OnHand, colpack29.InTransit, colpack29.BAM_OnOrder, colpack29.Warehouse_OnHand, 
                      colpack29.ReturnCenter_OnHand, colpack29.Qty_OnOrder, colpack29.Qty_OnBackorder, colpack29.Status, colpack29.IDate, colpack29.Store_Min, 
                      colpack29.Case_Qty, colpack29.week1, colpack29.week2, colpack29.week3, colpack29.week4, colpack29.week5, colpack29.week6, colpack29.week7, 
                      colpack29.week8, colpack29.week9, colpack29.week10, colpack29.week11, colpack29.week12, colpack29.week13, colpack29.LyWk1, colpack29.LyWk2, 
                      colpack29.LyWk3, colpack29.LyWk4, colpack29.LyWk5, colpack29.LyWk6, colpack29.LyWk7, colpack29.LyWk8, colpack29.LyWk9, colpack29.LyWk10, 
                      colpack29.LyWk11, colpack29.LyWk12, colpack29.LyWk13, colpack29.[Ly Wk 14], colpack29.LyWk15, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS LyWk16
FROM         colpack29 AS colpack29 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack29.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 253))
GROUP BY colpack29.Dept, colpack29.Class, colpack29.Sku_Number, colpack29.ISBN, colpack29.Title, colpack29.Author, colpack29.Pub_Code, 
                      colpack29.Sku_Type, colpack29.Retail, colpack29.BAM_OnHand, colpack29.InTransit, colpack29.BAM_OnOrder, colpack29.Warehouse_OnHand, 
                      colpack29.ReturnCenter_OnHand, colpack29.Qty_OnOrder, colpack29.Qty_OnBackorder, colpack29.Status, colpack29.IDate, colpack29.Store_Min, 
                      colpack29.Case_Qty, colpack29.week1, colpack29.week2, colpack29.week3, colpack29.week5, colpack29.week4, colpack29.week6, colpack29.week7, 
                      colpack29.week8, colpack29.week9, colpack29.week10, colpack29.week11, colpack29.week12, colpack29.week13, colpack29.LyWk1, colpack29.LyWk2, 
                      colpack29.LyWk3, colpack29.LyWk4, colpack29.LyWk5, colpack29.LyWk6, colpack29.LyWk7, colpack29.LyWk8, colpack29.LyWk9, colpack29.LyWk10, 
                      colpack29.LyWk11, colpack29.LyWk12, colpack29.LyWk13, colpack29.[Ly Wk 14], colpack29.LyWk15

-----------------build week 17
TRUNCATE TABLE Tmp_Load.dbo.colpack31
INSERT INTO Tmp_Load.dbo.colpack31
SELECT     colpack30.Dept, colpack30.Class, colpack30.Sku_Number, colpack30.ISBN, colpack30.Title, colpack30.Author, colpack30.Pub_Code, 
                      colpack30.Sku_Type, colpack30.Retail, colpack30.BAM_OnHand, colpack30.InTransit, colpack30.BAM_OnOrder, colpack30.Warehouse_OnHand, 
                      colpack30.ReturnCenter_OnHand, colpack30.Qty_OnOrder, colpack30.Qty_OnBackorder, colpack30.Status, colpack30.IDate, colpack30.Store_Min, 
                      colpack30.Case_Qty, colpack30.week1, colpack30.week2, colpack30.week3, colpack30.week4, colpack30.week5, colpack30.week6, colpack30.week7, 
                      colpack30.week8, colpack30.week9, colpack30.week10, colpack30.week11, colpack30.week12, colpack30.week13, colpack30.LyWk1, colpack30.LyWk2, 
                      colpack30.LyWk3, colpack30.LyWk4, colpack30.LyWk5, colpack30.LyWk6, colpack30.LyWk7, colpack30.LyWk8, colpack30.LyWk9, colpack30.LyWk10, 
                      colpack30.LyWk11, colpack30.LyWk12, colpack30.LyWk13, colpack30.[Ly Wk 14], colpack30.LyWk15, colpack30.LyWk16, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk17
FROM         colpack30 AS colpack30 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack30.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 246))
GROUP BY colpack30.Dept, colpack30.Class, colpack30.Sku_Number, colpack30.ISBN, colpack30.Title, colpack30.Author, colpack30.Pub_Code, 
                      colpack30.Sku_Type, colpack30.Retail, colpack30.BAM_OnHand, colpack30.InTransit, colpack30.BAM_OnOrder, colpack30.Warehouse_OnHand, 
                      colpack30.ReturnCenter_OnHand, colpack30.Qty_OnOrder, colpack30.Qty_OnBackorder, colpack30.Status, colpack30.IDate, colpack30.Store_Min, 
                      colpack30.Case_Qty, colpack30.week1, colpack30.week2, colpack30.week3, colpack30.week5, colpack30.week4, colpack30.week6, colpack30.week7, 
                      colpack30.week8, colpack30.week9, colpack30.week10, colpack30.week11, colpack30.week12, colpack30.week13, colpack30.LyWk1, colpack30.LyWk2, 
                      colpack30.LyWk3, colpack30.LyWk4, colpack30.LyWk5, colpack30.LyWk6, colpack30.LyWk7, colpack30.LyWk8, colpack30.LyWk9, colpack30.LyWk10, 
                      colpack30.LyWk11, colpack30.LyWk12, colpack30.LyWk13, colpack30.[Ly Wk 14], colpack30.LyWk15, colpack30.LyWk16


-----------------build week 18
TRUNCATE TABLE Tmp_Load.dbo.colpack32
INSERT INTO Tmp_Load.dbo.colpack32
SELECT     colpack31.Dept, colpack31.Class, colpack31.Sku_Number, colpack31.ISBN, colpack31.Title, colpack31.Author, colpack31.Pub_Code, 
                      colpack31.Sku_Type, colpack31.Retail, colpack31.BAM_OnHand, colpack31.InTransit, colpack31.BAM_OnOrder, colpack31.Warehouse_OnHand, 
                      colpack31.ReturnCenter_OnHand, colpack31.Qty_OnOrder, colpack31.Qty_OnBackorder, colpack31.Status, colpack31.IDate, colpack31.Store_Min, 
                      colpack31.Case_Qty, colpack31.week1, colpack31.week2, colpack31.week3, colpack31.week4, colpack31.week5, colpack31.week6, colpack31.week7, 
                      colpack31.week8, colpack31.week9, colpack31.week10, colpack31.week11, colpack31.week12, colpack31.week13, colpack31.LyWk1, colpack31.LyWk2, 
                      colpack31.LyWk3, colpack31.LyWk4, colpack31.LyWk5, colpack31.LyWk6, colpack31.LyWk7, colpack31.LyWk8, colpack31.LyWk9, colpack31.LyWk10, 
                      colpack31.LyWk11, colpack31.LyWk12, colpack31.LyWk13, colpack31.[Ly Wk 14], colpack31.LyWk15, colpack31.LyWk16, colpack31.LyWk17, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk18
FROM         colpack31 AS colpack31 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack31.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 239))
GROUP BY colpack31.Dept, colpack31.Class, colpack31.Sku_Number, colpack31.ISBN, colpack31.Title, colpack31.Author, colpack31.Pub_Code, 
                      colpack31.Sku_Type, colpack31.Retail, colpack31.BAM_OnHand, colpack31.InTransit, colpack31.BAM_OnOrder, colpack31.Warehouse_OnHand, 
                      colpack31.ReturnCenter_OnHand, colpack31.Qty_OnOrder, colpack31.Qty_OnBackorder, colpack31.Status, colpack31.IDate, colpack31.Store_Min, 
                      colpack31.Case_Qty, colpack31.week1, colpack31.week2, colpack31.week3, colpack31.week5, colpack31.week4, colpack31.week6, colpack31.week7, 
                      colpack31.week8, colpack31.week9, colpack31.week10, colpack31.week11, colpack31.week12, colpack31.week13, colpack31.LyWk1, colpack31.LyWk2, 
                      colpack31.LyWk3, colpack31.LyWk4, colpack31.LyWk5, colpack31.LyWk6, colpack31.LyWk7, colpack31.LyWk8, colpack31.LyWk9, colpack31.LyWk10, 
                      colpack31.LyWk11, colpack31.LyWk12, colpack31.LyWk13, colpack31.[Ly Wk 14], colpack31.LyWk15, colpack31.LyWk16, colpack31.LyWk17

-----------------build week 19
TRUNCATE TABLE Tmp_Load.dbo.colpack33
INSERT INTO Tmp_Load.dbo.colpack33
SELECT     colpack32.Dept, colpack32.Class, colpack32.Sku_Number, colpack32.ISBN, colpack32.Title, colpack32.Author, colpack32.Pub_Code, 
                      colpack32.Sku_Type, colpack32.Retail, colpack32.BAM_OnHand, colpack32.InTransit, colpack32.BAM_OnOrder, colpack32.Warehouse_OnHand, 
                      colpack32.ReturnCenter_OnHand, colpack32.Qty_OnOrder, colpack32.Qty_OnBackorder, colpack32.Status, colpack32.IDate, colpack32.Store_Min, 
                      colpack32.Case_Qty, colpack32.week1, colpack32.week2, colpack32.week3, colpack32.week4, colpack32.week5, colpack32.week6, colpack32.week7, 
                      colpack32.week8, colpack32.week9, colpack32.week10, colpack32.week11, colpack32.week12, colpack32.week13, colpack32.LyWk1, colpack32.LyWk2, 
                      colpack32.LyWk3, colpack32.LyWk4, colpack32.LyWk5, colpack32.LyWk6, colpack32.LyWk7, colpack32.LyWk8, colpack32.LyWk9, colpack32.LyWk10, 
                      colpack32.LyWk11, colpack32.LyWk12, colpack32.LyWk13, colpack32.[Ly Wk 14], colpack32.LyWk15, colpack32.LyWk16, colpack32.LyWk17, 
                      colpack32.LyWk18, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk19
FROM         colpack32 AS colpack32 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack32.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 232))
GROUP BY colpack32.Dept, colpack32.Class, colpack32.Sku_Number, colpack32.ISBN, colpack32.Title, colpack32.Author, colpack32.Pub_Code, 
                      colpack32.Sku_Type, colpack32.Retail, colpack32.BAM_OnHand, colpack32.InTransit, colpack32.BAM_OnOrder, colpack32.Warehouse_OnHand, 
                      colpack32.ReturnCenter_OnHand, colpack32.Qty_OnOrder, colpack32.Qty_OnBackorder, colpack32.Status, colpack32.IDate, colpack32.Store_Min, 
                      colpack32.Case_Qty, colpack32.week1, colpack32.week2, colpack32.week3, colpack32.week5, colpack32.week4, colpack32.week6, colpack32.week7, 
                      colpack32.week8, colpack32.week9, colpack32.week10, colpack32.week11, colpack32.week12, colpack32.week13, colpack32.LyWk1, colpack32.LyWk2, 
                      colpack32.LyWk3, colpack32.LyWk4, colpack32.LyWk5, colpack32.LyWk6, colpack32.LyWk7, colpack32.LyWk8, colpack32.LyWk9, colpack32.LyWk10, 
                      colpack32.LyWk11, colpack32.LyWk12, colpack32.LyWk13, colpack32.[Ly Wk 14], colpack32.LyWk15, colpack32.LyWk16, colpack32.LyWk17, 
                      colpack32.LyWk18

-----------------build week 20
TRUNCATE TABLE Tmp_Load.dbo.colpack34
INSERT INTO Tmp_Load.dbo.colpack34
SELECT     colpack33.Dept, colpack33.Class, colpack33.Sku_Number, colpack33.ISBN, colpack33.Title, colpack33.Author, colpack33.Pub_Code, 
                      colpack33.Sku_Type, colpack33.Retail, colpack33.BAM_OnHand, colpack33.InTransit, colpack33.BAM_OnOrder, colpack33.Warehouse_OnHand, 
                      colpack33.ReturnCenter_OnHand, colpack33.Qty_OnOrder, colpack33.Qty_OnBackorder, colpack33.Status, colpack33.IDate, colpack33.Store_Min, 
                      colpack33.Case_Qty, colpack33.week1, colpack33.week2, colpack33.week3, colpack33.week4, colpack33.week5, colpack33.week6, colpack33.week7, 
                      colpack33.week8, colpack33.week9, colpack33.week10, colpack33.week11, colpack33.week12, colpack33.week13, colpack33.LyWk1, colpack33.LyWk2, 
                      colpack33.LyWk3, colpack33.LyWk4, colpack33.LyWk5, colpack33.LyWk6, colpack33.LyWk7, colpack33.LyWk8, colpack33.LyWk9, colpack33.LyWk10, 
                      colpack33.LyWk11, colpack33.LyWk12, colpack33.LyWk13, colpack33.[Ly Wk 14], colpack33.LyWk15, colpack33.LyWk16, colpack33.LyWk17, 
                      colpack33.LyWk18, colpack33.LyWk19, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk20
FROM         colpack33 AS colpack33 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack33.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 225))
GROUP BY colpack33.Dept, colpack33.Class, colpack33.Sku_Number, colpack33.ISBN, colpack33.Title, colpack33.Author, colpack33.Pub_Code, 
                      colpack33.Sku_Type, colpack33.Retail, colpack33.BAM_OnHand, colpack33.InTransit, colpack33.BAM_OnOrder, colpack33.Warehouse_OnHand, 
                      colpack33.ReturnCenter_OnHand, colpack33.Qty_OnOrder, colpack33.Qty_OnBackorder, colpack33.Status, colpack33.IDate, colpack33.Store_Min, 
                      colpack33.Case_Qty, colpack33.week1, colpack33.week2, colpack33.week3, colpack33.week5, colpack33.week4, colpack33.week6, colpack33.week7, 
                      colpack33.week8, colpack33.week9, colpack33.week10, colpack33.week11, colpack33.week12, colpack33.week13, colpack33.LyWk1, colpack33.LyWk2, 
                      colpack33.LyWk3, colpack33.LyWk4, colpack33.LyWk5, colpack33.LyWk6, colpack33.LyWk7, colpack33.LyWk8, colpack33.LyWk9, colpack33.LyWk10, 
                      colpack33.LyWk11, colpack33.LyWk12, colpack33.LyWk13, colpack33.[Ly Wk 14], colpack33.LyWk15, colpack33.LyWk16, colpack33.LyWk17, 
                      colpack33.LyWk18, colpack33.LyWk19

-----------------build week 21
TRUNCATE TABLE Tmp_Load.dbo.colpack35
INSERT INTO Tmp_Load.dbo.colpack35
SELECT     colpack34.Dept, colpack34.Class, colpack34.Sku_Number, colpack34.ISBN, colpack34.Title, colpack34.Author, colpack34.Pub_Code, 
                      colpack34.Sku_Type, colpack34.Retail, colpack34.BAM_OnHand, colpack34.InTransit, colpack34.BAM_OnOrder, colpack34.Warehouse_OnHand, 
                      colpack34.ReturnCenter_OnHand, colpack34.Qty_OnOrder, colpack34.Qty_OnBackorder, colpack34.Status, colpack34.IDate, colpack34.Store_Min, 
                      colpack34.Case_Qty, colpack34.week1, colpack34.week2, colpack34.week3, colpack34.week4, colpack34.week5, colpack34.week6, colpack34.week7, 
                      colpack34.week8, colpack34.week9, colpack34.week10, colpack34.week11, colpack34.week12, colpack34.week13, colpack34.LyWk1, colpack34.LyWk2, 
                      colpack34.LyWk3, colpack34.LyWk4, colpack34.LyWk5, colpack34.LyWk6, colpack34.LyWk7, colpack34.LyWk8, colpack34.LyWk9, colpack34.LyWk10, 
                      colpack34.LyWk11, colpack34.LyWk12, colpack34.LyWk13, colpack34.[Ly Wk 14], colpack34.LyWk15, colpack34.LyWk16, colpack34.LyWk17, 
                      colpack34.LyWk18, colpack34.LyWk19, colpack34.LyWk20, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk21
FROM         colpack34 AS colpack34 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack34.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 218))
GROUP BY colpack34.Dept, colpack34.Class, colpack34.Sku_Number, colpack34.ISBN, colpack34.Title, colpack34.Author, colpack34.Pub_Code, 
                      colpack34.Sku_Type, colpack34.Retail, colpack34.BAM_OnHand, colpack34.InTransit, colpack34.BAM_OnOrder, colpack34.Warehouse_OnHand, 
                      colpack34.ReturnCenter_OnHand, colpack34.Qty_OnOrder, colpack34.Qty_OnBackorder, colpack34.Status, colpack34.IDate, colpack34.Store_Min, 
                      colpack34.Case_Qty, colpack34.week1, colpack34.week2, colpack34.week3, colpack34.week5, colpack34.week4, colpack34.week6, colpack34.week7, 
                      colpack34.week8, colpack34.week9, colpack34.week10, colpack34.week11, colpack34.week12, colpack34.week13, colpack34.LyWk1, colpack34.LyWk2, 
                      colpack34.LyWk3, colpack34.LyWk4, colpack34.LyWk5, colpack34.LyWk6, colpack34.LyWk7, colpack34.LyWk8, colpack34.LyWk9, colpack34.LyWk10, 
                      colpack34.LyWk11, colpack34.LyWk12, colpack34.LyWk13, colpack34.[Ly Wk 14], colpack34.LyWk15, colpack34.LyWk16, colpack34.LyWk17, 
                      colpack34.LyWk18, colpack34.LyWk19, colpack34.LyWk20


-----------------build week 22
TRUNCATE TABLE Tmp_Load.dbo.colpack36
INSERT INTO Tmp_Load.dbo.colpack36
SELECT     colpack35.Dept, colpack35.Class, colpack35.Sku_Number, colpack35.ISBN, colpack35.Title, colpack35.Author, colpack35.Pub_Code, 
                      colpack35.Sku_Type, colpack35.Retail, colpack35.BAM_OnHand, colpack35.InTransit, colpack35.BAM_OnOrder, colpack35.Warehouse_OnHand, 
                      colpack35.ReturnCenter_OnHand, colpack35.Qty_OnOrder, colpack35.Qty_OnBackorder, colpack35.Status, colpack35.IDate, colpack35.Store_Min, 
                      colpack35.Case_Qty, colpack35.week1, colpack35.week2, colpack35.week3, colpack35.week4, colpack35.week5, colpack35.week6, colpack35.week7, 
                      colpack35.week8, colpack35.week9, colpack35.week10, colpack35.week11, colpack35.week12, colpack35.week13, colpack35.LyWk1, colpack35.LyWk2, 
                      colpack35.LyWk3, colpack35.LyWk4, colpack35.LyWk5, colpack35.LyWk6, colpack35.LyWk7, colpack35.LyWk8, colpack35.LyWk9, colpack35.LyWk10, 
                      colpack35.LyWk11, colpack35.LyWk12, colpack35.LyWk13, colpack35.[Ly Wk 14], colpack35.LyWk15, colpack35.LyWk16, colpack35.LyWk17, 
                      colpack35.LyWk18, colpack35.LyWk19, colpack35.LyWk20, colpack35.LyWk21, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk22
FROM         colpack35 AS colpack35 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack35.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 211))
GROUP BY colpack35.Dept, colpack35.Class, colpack35.Sku_Number, colpack35.ISBN, colpack35.Title, colpack35.Author, colpack35.Pub_Code, 
                      colpack35.Sku_Type, colpack35.Retail, colpack35.BAM_OnHand, colpack35.InTransit, colpack35.BAM_OnOrder, colpack35.Warehouse_OnHand, 
                      colpack35.ReturnCenter_OnHand, colpack35.Qty_OnOrder, colpack35.Qty_OnBackorder, colpack35.Status, colpack35.IDate, colpack35.Store_Min, 
                      colpack35.Case_Qty, colpack35.week1, colpack35.week2, colpack35.week3, colpack35.week5, colpack35.week4, colpack35.week6, colpack35.week7, 
                      colpack35.week8, colpack35.week9, colpack35.week10, colpack35.week11, colpack35.week12, colpack35.week13, colpack35.LyWk1, colpack35.LyWk2, 
                      colpack35.LyWk3, colpack35.LyWk4, colpack35.LyWk5, colpack35.LyWk6, colpack35.LyWk7, colpack35.LyWk8, colpack35.LyWk9, colpack35.LyWk10, 
                      colpack35.LyWk11, colpack35.LyWk12, colpack35.LyWk13, colpack35.[Ly Wk 14], colpack35.LyWk15, colpack35.LyWk16, colpack35.LyWk17, 
                      colpack35.LyWk18, colpack35.LyWk19, colpack35.LyWk20, colpack35.LyWk21

-----------------build week 23
TRUNCATE TABLE Tmp_Load.dbo.colpack37
INSERT INTO Tmp_Load.dbo.colpack37
SELECT     colpack36.Dept, colpack36.Class, colpack36.Sku_Number, colpack36.ISBN, colpack36.Title, colpack36.Author, colpack36.Pub_Code, 
                      colpack36.Sku_Type, colpack36.Retail, colpack36.BAM_OnHand, colpack36.InTransit, colpack36.BAM_OnOrder, colpack36.Warehouse_OnHand, 
                      colpack36.ReturnCenter_OnHand, colpack36.Qty_OnOrder, colpack36.Qty_OnBackorder, colpack36.Status, colpack36.IDate, colpack36.Store_Min, 
                      colpack36.Case_Qty, colpack36.week1, colpack36.week2, colpack36.week3, colpack36.week4, colpack36.week5, colpack36.week6, colpack36.week7, 
                      colpack36.week8, colpack36.week9, colpack36.week10, colpack36.week11, colpack36.week12, colpack36.week13, colpack36.LyWk1, colpack36.LyWk2, 
                      colpack36.LyWk3, colpack36.LyWk4, colpack36.LyWk5, colpack36.LyWk6, colpack36.LyWk7, colpack36.LyWk8, colpack36.LyWk9, colpack36.LyWk10, 
                      colpack36.LyWk11, colpack36.LyWk12, colpack36.LyWk13, colpack36.[Ly Wk 14], colpack36.LyWk15, colpack36.LyWk16, colpack36.LyWk17, 
                      colpack36.LyWk18, colpack36.LyWk19, colpack36.LyWk20, colpack36.LyWk21, colpack36.LyWk22, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS LyWk23
FROM         colpack36 AS colpack36 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack36.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 204))
GROUP BY colpack36.Dept, colpack36.Class, colpack36.Sku_Number, colpack36.ISBN, colpack36.Title, colpack36.Author, colpack36.Pub_Code, 
                      colpack36.Sku_Type, colpack36.Retail, colpack36.BAM_OnHand, colpack36.InTransit, colpack36.BAM_OnOrder, colpack36.Warehouse_OnHand, 
                      colpack36.ReturnCenter_OnHand, colpack36.Qty_OnOrder, colpack36.Qty_OnBackorder, colpack36.Status, colpack36.IDate, colpack36.Store_Min, 
                      colpack36.Case_Qty, colpack36.week1, colpack36.week2, colpack36.week3, colpack36.week5, colpack36.week4, colpack36.week6, colpack36.week7, 
                      colpack36.week8, colpack36.week9, colpack36.week10, colpack36.week11, colpack36.week12, colpack36.week13, colpack36.LyWk1, colpack36.LyWk2, 
                      colpack36.LyWk3, colpack36.LyWk4, colpack36.LyWk5, colpack36.LyWk6, colpack36.LyWk7, colpack36.LyWk8, colpack36.LyWk9, colpack36.LyWk10, 
                      colpack36.LyWk11, colpack36.LyWk12, colpack36.LyWk13, colpack36.[Ly Wk 14], colpack36.LyWk15, colpack36.LyWk16, colpack36.LyWk17, 
                      colpack36.LyWk18, colpack36.LyWk19, colpack36.LyWk20, colpack36.LyWk21, colpack36.LyWk22

-----------------build week 23
TRUNCATE TABLE Tmp_Load.dbo.colpack38
INSERT INTO Tmp_Load.dbo.colpack38
SELECT     colpack37.Dept, colpack37.Class, colpack37.Sku_Number, colpack37.ISBN, colpack37.Title, colpack37.Author, colpack37.Pub_Code, 
                      colpack37.Sku_Type, colpack37.Retail, colpack37.BAM_OnHand, colpack37.InTransit, colpack37.BAM_OnOrder, colpack37.Warehouse_OnHand, 
                      colpack37.ReturnCenter_OnHand, colpack37.Qty_OnOrder, colpack37.Qty_OnBackorder, colpack37.Status, colpack37.IDate, colpack37.Store_Min, 
                      colpack37.Case_Qty, colpack37.week1, colpack37.week2, colpack37.week3, colpack37.week4, colpack37.week5, colpack37.week6, colpack37.week7, 
                      colpack37.week8, colpack37.week9, colpack37.week10, colpack37.week11, colpack37.week12, colpack37.week13, colpack37.LyWk1, colpack37.LyWk2, 
                      colpack37.LyWk3, colpack37.LyWk4, colpack37.LyWk5, colpack37.LyWk6, colpack37.LyWk7, colpack37.LyWk8, colpack37.LyWk9, colpack37.LyWk10, 
                      colpack37.LyWk11, colpack37.LyWk12, colpack37.LyWk13, colpack37.[Ly Wk 14], colpack37.LyWk15, colpack37.LyWk16, colpack37.LyWk17, 
                      colpack37.LyWk18, colpack37.LyWk19, colpack37.LyWk20, colpack37.LyWk21, colpack37.LyWk22, colpack37.LyWk23, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk24
FROM         colpack37 AS colpack37 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack37.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 197))
GROUP BY colpack37.Dept, colpack37.Class, colpack37.Sku_Number, colpack37.ISBN, colpack37.Title, colpack37.Author, colpack37.Pub_Code, 
                      colpack37.Sku_Type, colpack37.Retail, colpack37.BAM_OnHand, colpack37.InTransit, colpack37.BAM_OnOrder, colpack37.Warehouse_OnHand, 
                      colpack37.ReturnCenter_OnHand, colpack37.Qty_OnOrder, colpack37.Qty_OnBackorder, colpack37.Status, colpack37.IDate, colpack37.Store_Min, 
                      colpack37.Case_Qty, colpack37.week1, colpack37.week2, colpack37.week3, colpack37.week5, colpack37.week4, colpack37.week6, colpack37.week7, 
                      colpack37.week8, colpack37.week9, colpack37.week10, colpack37.week11, colpack37.week12, colpack37.week13, colpack37.LyWk1, colpack37.LyWk2, 
                      colpack37.LyWk3, colpack37.LyWk4, colpack37.LyWk5, colpack37.LyWk6, colpack37.LyWk7, colpack37.LyWk8, colpack37.LyWk9, colpack37.LyWk10, 
                      colpack37.LyWk11, colpack37.LyWk12, colpack37.LyWk13, colpack37.[Ly Wk 14], colpack37.LyWk15, colpack37.LyWk16, colpack37.LyWk17, 
                      colpack37.LyWk18, colpack37.LyWk19, colpack37.LyWk20, colpack37.LyWk21, colpack37.LyWk22, colpack37.LyWk23

-----------------build week 24
TRUNCATE TABLE Tmp_Load.dbo.colpack39
INSERT INTO Tmp_Load.dbo.colpack39
SELECT     colpack38.Dept, colpack38.Class, colpack38.Sku_Number, colpack38.ISBN, colpack38.Title, colpack38.Author, colpack38.Pub_Code, 
                      colpack38.Sku_Type, colpack38.Retail, colpack38.BAM_OnHand, colpack38.InTransit, colpack38.BAM_OnOrder, colpack38.Warehouse_OnHand, 
                      colpack38.ReturnCenter_OnHand, colpack38.Qty_OnOrder, colpack38.Qty_OnBackorder, colpack38.Status, colpack38.IDate, colpack38.Store_Min, 
                      colpack38.Case_Qty, colpack38.week1, colpack38.week2, colpack38.week3, colpack38.week4, colpack38.week5, colpack38.week6, colpack38.week7, 
                      colpack38.week8, colpack38.week9, colpack38.week10, colpack38.week11, colpack38.week12, colpack38.week13, colpack38.LyWk1, colpack38.LyWk2, 
                      colpack38.LyWk3, colpack38.LyWk4, colpack38.LyWk5, colpack38.LyWk6, colpack38.LyWk7, colpack38.LyWk8, colpack38.LyWk9, colpack38.LyWk10, 
                      colpack38.LyWk11, colpack38.LyWk12, colpack38.LyWk13, colpack38.[Ly Wk 14], colpack38.LyWk15, colpack38.LyWk16, colpack38.LyWk17, 
                      colpack38.LyWk18, colpack38.LyWk19, colpack38.LyWk20, colpack38.LyWk21, colpack38.LyWk22, colpack38.LyWk23, colpack38.LyWk24, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk25
FROM         colpack38 AS colpack38 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack38.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 190))
GROUP BY colpack38.Dept, colpack38.Class, colpack38.Sku_Number, colpack38.ISBN, colpack38.Title, colpack38.Author, colpack38.Pub_Code, 
                      colpack38.Sku_Type, colpack38.Retail, colpack38.BAM_OnHand, colpack38.InTransit, colpack38.BAM_OnOrder, colpack38.Warehouse_OnHand, 
                      colpack38.ReturnCenter_OnHand, colpack38.Qty_OnOrder, colpack38.Qty_OnBackorder, colpack38.Status, colpack38.IDate, colpack38.Store_Min, 
                      colpack38.Case_Qty, colpack38.week1, colpack38.week2, colpack38.week3, colpack38.week5, colpack38.week4, colpack38.week6, colpack38.week7, 
                      colpack38.week8, colpack38.week9, colpack38.week10, colpack38.week11, colpack38.week12, colpack38.week13, colpack38.LyWk1, colpack38.LyWk2, 
                      colpack38.LyWk3, colpack38.LyWk4, colpack38.LyWk5, colpack38.LyWk6, colpack38.LyWk7, colpack38.LyWk8, colpack38.LyWk9, colpack38.LyWk10, 
                      colpack38.LyWk11, colpack38.LyWk12, colpack38.LyWk13, colpack38.[Ly Wk 14], colpack38.LyWk15, colpack38.LyWk16, colpack38.LyWk17, 
                      colpack38.LyWk18, colpack38.LyWk19, colpack38.LyWk20, colpack38.LyWk21, colpack38.LyWk22, colpack38.LyWk23, colpack38.LyWk24

-----------------build week 25
TRUNCATE TABLE Tmp_Load.dbo.colpack40
INSERT INTO Tmp_Load.dbo.colpack40
SELECT     colpack39.Dept, colpack39.Class, colpack39.Sku_Number, colpack39.ISBN, colpack39.Title, colpack39.Author, colpack39.Pub_Code, 
                      colpack39.Sku_Type, colpack39.Retail, colpack39.BAM_OnHand, colpack39.InTransit, colpack39.BAM_OnOrder, colpack39.Warehouse_OnHand, 
                      colpack39.ReturnCenter_OnHand, colpack39.Qty_OnOrder, colpack39.Qty_OnBackorder, colpack39.Status, colpack39.IDate, colpack39.Store_Min, 
                      colpack39.Case_Qty, colpack39.week1, colpack39.week2, colpack39.week3, colpack39.week4, colpack39.week5, colpack39.week6, colpack39.week7, 
                      colpack39.week8, colpack39.week9, colpack39.week10, colpack39.week11, colpack39.week12, colpack39.week13, colpack39.LyWk1, colpack39.LyWk2, 
                      colpack39.LyWk3, colpack39.LyWk4, colpack39.LyWk5, colpack39.LyWk6, colpack39.LyWk7, colpack39.LyWk8, colpack39.LyWk9, colpack39.LyWk10, 
                      colpack39.LyWk11, colpack39.LyWk12, colpack39.LyWk13, colpack39.[Ly Wk 14], colpack39.LyWk15, colpack39.LyWk16, colpack39.LyWk17, 
                      colpack39.LyWk18, colpack39.LyWk19, colpack39.LyWk20, colpack39.LyWk21, colpack39.LyWk22, colpack39.LyWk23, colpack39.LyWk24, 
                      colpack39.LyWk25, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LyWk26
FROM         colpack39 AS colpack39 LEFT OUTER JOIN
                      DssData.dbo.Weekly_Sales ON colpack39.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE() - 183))
GROUP BY colpack39.Dept, colpack39.Class, colpack39.Sku_Number, colpack39.ISBN, colpack39.Title, colpack39.Author, colpack39.Pub_Code, 
                      colpack39.Sku_Type, colpack39.Retail, colpack39.BAM_OnHand, colpack39.InTransit, colpack39.BAM_OnOrder, colpack39.Warehouse_OnHand, 
                      colpack39.ReturnCenter_OnHand, colpack39.Qty_OnOrder, colpack39.Qty_OnBackorder, colpack39.Status, colpack39.IDate, colpack39.Store_Min, 
                      colpack39.Case_Qty, colpack39.week1, colpack39.week2, colpack39.week3, colpack39.week5, colpack39.week4, colpack39.week6, colpack39.week7, 
                      colpack39.week8, colpack39.week9, colpack39.week10, colpack39.week11, colpack39.week12, colpack39.week13, colpack39.LyWk1, colpack39.LyWk2, 
                      colpack39.LyWk3, colpack39.LyWk4, colpack39.LyWk5, colpack39.LyWk6, colpack39.LyWk7, colpack39.LyWk8, colpack39.LyWk9, colpack39.LyWk10, 
                      colpack39.LyWk11, colpack39.LyWk12, colpack39.LyWk13, colpack39.[Ly Wk 14], colpack39.LyWk15, colpack39.LyWk16, colpack39.LyWk17, 
                      colpack39.LyWk18, colpack39.LyWk19, colpack39.LyWk20, colpack39.LyWk21, colpack39.LyWk22, colpack39.LyWk23, colpack39.LyWk24, 
                      colpack39.LyWk25

TRUNCATE TABLE Tmp_Load.dbo.colpack41
INSERT INTO Tmp_Load.dbo.colpack41
SELECT     INVMST.Inner_Pack, INVMST.Min_Order_Qty, INVMST.Stock_Multiplier, Tmp_Load.dbo.colpack40.Dept, Tmp_Load.dbo.colpack40.Class, 
                      Tmp_Load.dbo.colpack40.Sku_Number, Tmp_Load.dbo.colpack40.ISBN, Tmp_Load.dbo.colpack40.Title, Tmp_Load.dbo.colpack40.Author, 
                      Tmp_Load.dbo.colpack40.Pub_Code, Tmp_Load.dbo.colpack40.Sku_Type, Tmp_Load.dbo.colpack40.Retail, Tmp_Load.dbo.colpack40.BAM_OnHand, 
                      Tmp_Load.dbo.colpack40.InTransit, Tmp_Load.dbo.colpack40.BAM_OnOrder, Tmp_Load.dbo.colpack40.Warehouse_OnHand, 
                      Tmp_Load.dbo.colpack40.ReturnCenter_OnHand, Tmp_Load.dbo.colpack40.Qty_OnOrder, Tmp_Load.dbo.colpack40.Qty_OnBackorder, 
                      Tmp_Load.dbo.colpack40.Status, Tmp_Load.dbo.colpack40.IDate, Tmp_Load.dbo.colpack40.Store_Min, Tmp_Load.dbo.colpack40.Case_Qty, 
                      Tmp_Load.dbo.colpack40.week2, Tmp_Load.dbo.colpack40.week1, Tmp_Load.dbo.colpack40.week4, Tmp_Load.dbo.colpack40.week3, 
                      Tmp_Load.dbo.colpack40.week5, Tmp_Load.dbo.colpack40.week6, Tmp_Load.dbo.colpack40.week7, Tmp_Load.dbo.colpack40.week8, 
                      Tmp_Load.dbo.colpack40.week9, Tmp_Load.dbo.colpack40.week10, Tmp_Load.dbo.colpack40.week11, Tmp_Load.dbo.colpack40.week12, 
                      Tmp_Load.dbo.colpack40.week13, Tmp_Load.dbo.colpack40.LyWk1, Tmp_Load.dbo.colpack40.LyWk2, Tmp_Load.dbo.colpack40.LyWk3, 
                      Tmp_Load.dbo.colpack40.LyWk4, Tmp_Load.dbo.colpack40.LyWk5, Tmp_Load.dbo.colpack40.LyWk6, Tmp_Load.dbo.colpack40.LyWk7, 
                      Tmp_Load.dbo.colpack40.LyWk8, Tmp_Load.dbo.colpack40.LyWk9, Tmp_Load.dbo.colpack40.LyWk10, Tmp_Load.dbo.colpack40.LyWk11, 
                      Tmp_Load.dbo.colpack40.LyWk12, Tmp_Load.dbo.colpack40.LyWk13, Tmp_Load.dbo.colpack40.[Ly Wk 14], Tmp_Load.dbo.colpack40.LyWk15, 
                      Tmp_Load.dbo.colpack40.LyWk16, Tmp_Load.dbo.colpack40.LyWk17, Tmp_Load.dbo.colpack40.LyWk18, Tmp_Load.dbo.colpack40.LyWk19, 
                      Tmp_Load.dbo.colpack40.LyWk20, Tmp_Load.dbo.colpack40.LyWk21, Tmp_Load.dbo.colpack40.LyWk22, Tmp_Load.dbo.colpack40.LyWk23, 
                      Tmp_Load.dbo.colpack40.LyWk24, Tmp_Load.dbo.colpack40.LyWk25, Tmp_Load.dbo.colpack40.LyWk26
FROM         INVMST INNER JOIN
                      Tmp_Load.dbo.colpack40 ON INVMST.Sku_Number = Tmp_Load.dbo.colpack40.Sku_Number

select * From Tmp_Load.dbo.colpack41
GO
