USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_HSDET]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_HSDET]
as
--
truncate table reference.dbo.hsdet
--
insert into	reference.dbo.hsdet
SELECT Header_Key
      ,Company_Number
      ,Warehouse_Number
      ,Store_Number
      ,staging.dbo.fn_IntToDate(Invoice_Date) as Invoice_Date
      ,ISBN
      ,Qty_Ordered
      ,Qty_Shipped
      ,Retail_Price
      ,Discount
      ,Code
  FROM Staging.dbo.wrk_HSDET
--
truncate table reference.dbo.hshed
--
insert into	reference.dbo.hshed
SELECT Header_Key
      ,staging.dbo.fn_LongIntToDate(Invoice_Date)
      ,Selling_Type
  FROM Staging.dbo.wrk_HSHED

GO
