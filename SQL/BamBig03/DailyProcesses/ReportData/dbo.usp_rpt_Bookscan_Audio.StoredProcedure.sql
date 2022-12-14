USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Bookscan_Audio]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[usp_rpt_Bookscan_Audio]
as
DECLARE @MaxWeek int 
DECLARE @YearNumber int 
DECLARE @LS smalldatetime

select @LS = staging.dbo.fn_Last_Saturday(getdate())

SELECT  @YearNumber = Fiscal_Year
FROM    reference.dbo.calendar_dim
WHERE   day_date = staging.dbo.fn_dateonly(getdate())

SELECT  @MaxWeek = max(WeekNumber)
FROM    reference.dbo.Bookscan_Audio
WHERE   yearnumber = @YearNumber

SELECT	@LS as WeekEnding,
		Bookscan_Audio.WeekNumber, 
		Bookscan_Audio.ISBN, 
        Bookscan_Audio.Title, 
		Bookscan_Audio.Author, 
        Bookscan_Audio.Publisher, 
		Bookscan_Audio.Date_of_Publication, 
        Bookscan_Audio.Price, 
        Bookscan_Audio.TW_Sales AS Bookscan_Sls_U, 
        DssData.dbo.CARD.Week1Units AS BAM_Sls_U, 
        DssData.dbo.CARD.Week1Units / Bookscan_Audio.TW_Sales AS BAM_Pct_Mkt
FROM    Reference.dbo.Bookscan_Audio LEFT OUTER JOIN
        DssData.dbo.CARD ON 
        Bookscan_Audio.ISBN = DssData.dbo.CARD.ISBN
WHERE  (Bookscan_Audio.YearNumber = @YearNumber AND 
        Bookscan_Audio.WeekNumber = @MaxWeek)
GROUP BY Bookscan_Audio.Publisher, Bookscan_Audio.Date_of_Publication, 
         Bookscan_Audio.Price, Bookscan_Audio.TW_Sales, 
         DssData.dbo.CARD.Week1Units, 
         DssData.dbo.CARD.Week1Units / Bookscan_Audio.TW_Sales, 
         Bookscan_Audio.ISBN, Bookscan_Audio.Title, 
         Bookscan_Audio.Author, Bookscan_Audio.WeekNumber
ORDER BY BAM_Pct_Mkt                        


GO
