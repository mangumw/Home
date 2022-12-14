USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Yesterday_Receipt]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_Yesterday_Receipt] 
@buyer varchar(50),
@Sku_Type varchar(20)
as
declare @strsql nvarchar(2000)

set @strsql = 'SELECT	Reference.dbo.Category_Master.Buyername,'
set @strsql = @strsql + 'reference.dbo.Receipt_Tracking.Day_Date,'
set @strsql = @strsql + 'reference.dbo.Receipt_Tracking.PO AS PO,'
set @strsql = @strsql + 'reference.dbo.item_master.PubCode, '
set @strsql = @strsql + 'Reference.dbo.Item_Master.ISBN, '
set @strsql = @strsql + 'Reference.dbo.Item_Master.Title, '
set @strsql = @strsql + 'Reference.dbo.Item_Master.sku_Type, '
set @strsql = @strsql + 'reference.dbo.Receipt_Tracking.Unit_Cost AS Unit_Cost, '
set @strsql = @strsql + 'reference.dbo.Receipt_Tracking.Unit_Rtl AS Unit_Rtl, '
set @strsql = @strsql + 'Sum(reference.dbo.Receipt_Tracking.Rec_Qty) AS Rec_qty, '
set @strsql = @strsql + 'Sum(reference.dbo.Receipt_Tracking.Ord_Qty) AS Ord_qty, '
set @strsql = @strsql + 'reference.dbo.Receipt_Tracking.Day_Date '
set @strsql = @strsql + 'FROM	Reference.dbo.Receipt_Tracking INNER JOIN Reference.dbo.Item_Master '
set @strsql = @strsql + 'ON		reference.dbo.Receipt_Tracking.ISBN = Reference.dbo.Item_Master.ISBN '
set @strsql = @strsql + ' inner join reference.dbo.category_master '
set @strsql = @strsql + 'on reference.dbo.category_master.dept = reference.dbo.item_master.dept and '
set @strsql = @strsql + ' reference.dbo.category_master.subdept = reference.dbo.item_master.sdept and '
set @strsql = @strsql + ' reference.dbo.category_master.class = reference.dbo.item_master.class and '
set @strsql = @strsql + ' reference.dbo.category_master.subclass = reference.dbo.item_master.sclass '
set @strsql = @strsql + 'WHERE reference.dbo.Receipt_Tracking.day_date = dateadd(dd,-1,staging.dbo.fn_dateonly(getdate())'
GO
