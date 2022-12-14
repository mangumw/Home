USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_jenny]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_jenny]
as 

truncate table staging.dbo.markdown_jenny
insert into staging.dbo.markdown_jenny

SELECT     Reference.dbo.Import_Markdown.ISBN, Reference.dbo.Item_Master.Title, Reference.dbo.Item_Master.Author, 
                      Reference.dbo.Import_Markdown.Directive, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, 
                      Reference.dbo.INVBAL.Store_Number, Reference.dbo.INVBAL.On_Hand
FROM         Reference.dbo.Import_Markdown INNER JOIN
                      Reference.dbo.Item_Master ON Reference.dbo.Import_Markdown.ISBN = Reference.dbo.Item_Master.ISBN INNER JOIN
                      Reference.dbo.INVBAL ON Reference.dbo.Item_Master.SKU_Number = Reference.dbo.INVBAL.sku_number
WHERE     (Reference.dbo.INVBAL.On_Hand > 0)
GO
