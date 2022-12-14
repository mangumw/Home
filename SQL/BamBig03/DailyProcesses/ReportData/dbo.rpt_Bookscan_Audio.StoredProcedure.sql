USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Bookscan_Audio]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rpt_Bookscan_Audio]
as

DECLARE @YearNumber int 
DECLARE @WeekNumber int 
declare @LS Smalldatetime

select @LS = staging.dbo.fn_Last_Saturday(getdate())
SELECT  @YearNumber = Fiscal_Year
FROM          calendar_dim
WHERE      day_date = staging.dbo.fn_dateonly(getdate())
SELECT     @weeknumber = max(WeekNumber)
FROM         bookscan_audio
WHERE     yearnumber = @yearnumber

SELECT  @LS as WeekEnding,
		Bookscan_Audio.WeekNumber, 
		Bookscan_Audio.ISBN, 
        Bookscan_Audio.Title, 
		Bookscan_Audio.Author, 
        Bookscan_Audio.Publisher, Bookscan_Audio.Date_of_Publication, 
        Bookscan_Audio.Price, 
        Bookscan_Audio.TW_Sales AS Bookscan_Sls_U, 
        DssData.dbo.CARD.Week1Units AS BAM_Sls_U, 
        DssData.dbo.CARD.Week1Units / Bookscan_Audio.TW_Sales AS BAM_Pct_Mkt
FROM    Bookscan_Audio LEFT OUTER JOIN
        DssData.dbo.CARD ON 
        Bookscan_Audio.ISBN = DssData.dbo.CARD.ISBN
WHERE     (Bookscan_Audio.YearNumber = @YearNumber)
GROUP BY Bookscan_Audio.Publisher, 
         Bookscan_Audio.Date_of_Publication, Bookscan_Audio.Price, 
         Bookscan_Audio.TW_Sales, DssData.dbo.CARD.Week1Units, 
         DssData.dbo.CARD.Week1Units / Bookscan_Audio.TW_Sales, 
         Bookscan_Audio.ISBN, Bookscan_Audio.Title, 
         Bookscan_Audio.Author, Bookscan_Audio.WeekNumber
HAVING      (Bookscan_Audio.WeekNumber = @WeekNumber)
ORDER BY BAM_Pct_Mkt
GO
