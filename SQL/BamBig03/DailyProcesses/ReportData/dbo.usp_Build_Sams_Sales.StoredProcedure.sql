USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Sams_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Sams_Sales]
as
declare @seldate varchar(20)
declare @sql nvarchar(1000)
select @seldate = dateadd(dd,-28,staging.dbo.fn_dateonly(getdate()))

drop table ReportData.dbo.Sams_Sales
--
select @sql = 'SELECT  t1.Customer_Number,t1.Line_Item_Type, t1.Item_Number, t1.Item_Desc_1, NULL as Item_Desc_2, t1.Qty_Ordered, t1.Qty_Shipped, 0 as OBBOQT, t1.Item_Class, t1.Item_SubClass, t1.List_Price, t1.Actual_Sell_Price, t1.Total_Line_Amount, 0 as OBSYAM, 0 as OBLNVL, t1.Invoice_Cost, t1.Invoice_Date as OBIVDT '
select @sql = @sql + 'into	ReportData.dbo.Sams_Sales FROM	Reference.dbo.HSDET t1 '
select @sql = @sql + 'where t1.Customer_Number=2115 AND t1.Invoice_Date>= ' + '''' + @seldate + '''' + ' '
select @sql = @sql + ' GROUP BY t1.Customer_Number, t1.Line_Item_Type, t1.Item_Number, t1.Item_Desc_1, t1.Qty_Ordered, t1.Qty_Shipped, t1.Item_Class, t1.Item_SubClass, t1.List_Price, t1.Actual_Sell_Price, t1.Total_Line_Amount, t1.Invoice_Cost, t1.Invoice_Date '
execute sp_executesql @sql








GO
