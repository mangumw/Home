USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Bookscan_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_Bookscan_Report]
as
drop table ReportDAta.dbo.rpt_Bookscan_Report
SELECT TOP (250) 
		Reference.dbo.Bookscan.ISBN, 
		Reference.dbo.Bookscan.Title, 
		Reference.dbo.Bookscan.Author, 
		Reference.dbo.Bookscan.Imprint, 
		Reference.dbo.Bookscan.Publisher, 
		Reference.dbo.Bookscan.PubDate, 
		Reference.dbo.Bookscan.BISACCAT, 
		Reference.dbo.Bookscan.Binding, 
		Reference.dbo.Bookscan.YearNumber, 
		Reference.dbo.Bookscan.WeekNumber, 
		Reference.dbo.Bookscan.Retail_Price, 
		Reference.dbo.Bookscan.Week_Units, 
		Reference.dbo.Bookscan.YTD_Units, 
		DssData.dbo.CARD.Week1Units + SUM(Reference.dbo.DC_Detail.qty_ship) AS BAM_Units, 
		DssData.dbo.CARD.ISBN AS Expr2, 
		Reference.dbo.DC_Detail.pid, 
		DssData.dbo.CARD.Week1Units
into	ReportData.dbo.rpt_Bookscan_Report
FROM	Reference.dbo.DC_Detail INNER JOIN
		Reference.dbo.Bookscan INNER JOIN
		DssData.dbo.CARD ON Reference.dbo.Bookscan.ISBN = DssData.dbo.CARD.EAN ON 
		Reference.dbo.DC_Detail.pid = dssdata.dbo.CARD.ISBN
WHERE	(Staging.dbo.fn_DateOnly(Reference.dbo.DC_Detail.time_shipped) IN
			(SELECT Cal2.day_date
			FROM	Reference.dbo.Calendar_Dim INNER JOIN
					Reference.dbo.Calendar_Dim AS Cal2 ON 
					Reference.dbo.Calendar_Dim.fiscal_year_week = Cal2.fiscal_year_week AND 
					Reference.dbo.Calendar_Dim.fiscal_year = Cal2.fiscal_year
WHERE (Staging.dbo.fn_DateOnly(Reference.dbo.Calendar_Dim.day_date) = Staging.dbo.fn_DateOnly(GETDATE() - 7))))
GROUP BY Reference.dbo.Bookscan.ISBN, Reference.dbo.Bookscan.Title, Reference.dbo.Bookscan.Author, Reference.dbo.Bookscan.Imprint, 
Reference.dbo.Bookscan.Publisher, Reference.dbo.Bookscan.PubDate, Reference.dbo.Bookscan.BISACCAT, Reference.dbo.Bookscan.Binding, 
Reference.dbo.Bookscan.YearNumber, Reference.dbo.Bookscan.WeekNumber, Reference.dbo.Bookscan.Retail_Price, 
Reference.dbo.Bookscan.Week_Units, Reference.dbo.Bookscan.YTD_Units, DssData.dbo.CARD.ISBN, Reference.dbo.DC_Detail.pid, 
DssData.dbo.CARD.Week1Units
ORDER BY Reference.dbo.Bookscan.YearNumber DESC, Reference.dbo.Bookscan.WeekNumber DESC, Reference.dbo.Bookscan.Week_Units DESC




GO
