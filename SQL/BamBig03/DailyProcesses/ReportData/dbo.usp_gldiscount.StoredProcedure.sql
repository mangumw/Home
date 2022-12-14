USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_gldiscount]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure 
 [dbo].[usp_gldiscount] as

truncate table staging.dbo.gldiscount_master
insert into staging.dbo.gldiscount_master

SELECT     Reference.dbo.ITMST.ISBN, Reference.dbo.ITMST.Title, Reference.dbo.HSDET.Retail_Price, Reference.dbo.HSDET.Invoice_Date, 
                      Reference.dbo.HSDET.Store_Number, Reference.dbo.ITMST.Class AS dept, SUM(Reference.dbo.HSDET.Qty_Shipped) AS shipped_qty, 
                      Reference.dbo.HSDET.Discount AS billing_discount, Staging.dbo.gldept.Discount AS gl_discount, 
                      Reference.dbo.HSDET.Discount - Staging.dbo.gldept.Discount AS discount_var, 
                      Reference.dbo.HSDET.Discount * (Reference.dbo.HSDET.Qty_Shipped * Reference.dbo.HSDET.Retail_Price) / 100 AS billing_discount_ttl, 
                      Staging.dbo.gldept.Discount * (Reference.dbo.HSDET.Qty_Shipped * Reference.dbo.HSDET.Retail_Price) / 100 AS gl_discount_ttl
FROM         Reference.dbo.HSDET INNER JOIN
                      Reference.dbo.HSHED ON Reference.dbo.HSDET.Header_Key = Reference.dbo.HSHED.Header_Key INNER JOIN
                      Reference.dbo.ITMST ON Reference.dbo.HSDET.ISBN = Reference.dbo.ITMST.ISBN INNER JOIN
                      Staging.dbo.gldept ON Reference.dbo.ITMST.Class = Staging.dbo.gldept.DEPT
GROUP BY Reference.dbo.ITMST.Class, Reference.dbo.HSDET.Discount, Staging.dbo.gldept.Discount, 
                      Reference.dbo.HSDET.Discount - Staging.dbo.gldept.Discount, Reference.dbo.ITMST.ISBN, Reference.dbo.ITMST.Title, 
                      Reference.dbo.HSDET.Invoice_Date, Reference.dbo.HSDET.Retail_Price, Reference.dbo.HSDET.Store_Number, 
                      Reference.dbo.HSDET.Discount * (Reference.dbo.HSDET.Qty_Shipped * Reference.dbo.HSDET.Retail_Price) / 100, 
                      Staging.dbo.gldept.Discount * (Reference.dbo.HSDET.Qty_Shipped * Reference.dbo.HSDET.Retail_Price) / 100
HAVING      (Reference.dbo.HSDET.Discount - Staging.dbo.gldept.Discount <> 0) AND (Reference.dbo.HSDET.Store_Number BETWEEN 100 AND 1000)

SELECT     ISBN, Title, Retail_Price, Invoice_Date, Store_Number, dept, shipped_qty, billing_discount, gl_discount, discount_var, billing_discount_ttl, 
                      gl_discount_ttl, billing_discount_ttl - gl_discount_ttl AS ttl_discount_variance
FROM         Staging.dbo.gldiscount_master
GO
