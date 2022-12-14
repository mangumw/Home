USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Stocked_Out_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


------------------------------------------------------------------
-- This proc is used to gather the data to be used in the		--
-- Stocked Out Report.                                          --
--																--
-- It take two parameters: 1) SortOrder determines which column --
-- to put in the Order By And 2) whether it should be listed    --
-- Asc or Desc  
------------------------------------------------------------------                                                                      
--

CREATE procedure [dbo].[usp_rpt_Stocked_Out_Report]
@SortOrder varchar(15),
@AscDec varchar(4)
as
	SET NOCOUNT ON;
--
declare @strsql nvarchar(1500)
--
select @strsql = 'SELECT     DssData.dbo.CARD.Buyer_Init AS [AWBC Buyer], DssData.dbo.CARD.Pub_Code AS [Pub Code], Extended_Pidstats.numstockedout AS Stockout,'
select @strsql = @strsql + 'DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Title, DssData.dbo.CARD.Author, DssData.dbo.CARD.IDate, DssData.dbo.CARD.Retail, '
select @strsql = @strsql + ' DssData.dbo.CARD.BAM_OnHand AS [Store OH], DssData.dbo.CARD.Warehouse_OnHand AS [Whse OH], DssData.dbo.CARD.InTransit AS [IT Store],'
select @strsql = @strsql + 'DssData.dbo.CARD.Qty_OnOrder AS [Whse OO], DssData.dbo.CARD.WTD_Units AS WTDU, DssData.dbo.CARD.Week1Units AS WK1U, '
select @strsql = @strsql + 'DssData.dbo.CARD.Week2Units AS WK2U, DssData.dbo.CARD.Week3Units AS WK3U '
select @strsql = @strsql + 'FROM DssData.dbo.CARD INNER JOIN Reference.dbo.Extended_Pidstats ON DssData.dbo.CARD.ISBN = Reference.dbo.Extended_Pidstats.pid '
select @strsql = @strsql + 'WHERE (Reference.dbo.Extended_Pidstats.numstockedout > 0) AND (DssData.dbo.CARD.Sku_Type = ''B'')'
select @strsql = @strsql + ' order by ' + @SortOrder + ' ' + @AscDec
--
EXEC sp_executesql @strsql






 

 



GO
