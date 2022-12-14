USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spLoadMarkdownUpload_OnHands]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[spLoadMarkdownUpload_OnHands]

AS
/*
*/

DECLARE @CurDateTime datetime
SET @CurDateTime = GETDATE()

DECLARE @CurDate datetime
SET @CurDate = CAST(CONVERT(varchar, @CurDateTime, 112) AS datetime)	-- Zeroes time portion

-- Determine start of FY
DECLARE @FYStartDt datetime
SET @FYStartDt = (SELECT MIN(CalDate) FROM BAMITR05.MiscSales.dbo.FiscCal WHERE FiscYear = (
	SELECT FiscYear FROM BAMITR05.MiscSales.dbo.FiscCal WHERE CalDate = @CurDate
	)
	)

---------------------------------------------------
-- Clear, then populate Markdown_OnHand_Upload
TRUNCATE TABLE Markdown_OnHand_Upload

INSERT INTO Markdown_OnHand_Upload
SELECT 
	-- LTRIM(RTRIM( SUBSTRING(I.IMPREF, 3, LEN(I.IMPREF)) )) [I_BATCHNO], LTRIM(RTRIM(I.IMPITM)) [I_ITEMKEY], 
	m.storeno [IMPLOC], 
	m.itemkey [IMPITM], 
	CONVERT(varchar, m.postdate, 112) [IMPDAT], 
	m.qty [IMPQTY], 
	r.reasondesc [IMPREA], 
	'MD'+ CAST(m.batchno AS varchar) [IMPREF], 
	LinePos [IMPLIN]
FROM Markdowns.dbo.Markdowns m 
INNER JOIN Markdowns.dbo.Reasons r ON (m.reasonid = r.reasonid)
/*
LEFT JOIN BKL400_MM4R4LIB.BKL400.MM4R4LIB.MRKIMP I ON (
	LTRIM(RTRIM(M.BatchNo)) = LTRIM(RTRIM( SUBSTRING(I.IMPREF, 3, LEN(I.IMPREF)) ))
	AND
	LTRIM(RTRIM(M.ItemKey)) = LTRIM(RTRIM(I.IMPITM))
)
*/
WHERE m.newprice = 0 
	AND m.posted = 1 
	AND m.validated = 1
	AND m.invenphysadj is null
	--and LTRIM(RTRIM( SUBSTRING(I.IMPREF, 3, LEN(I.IMPREF)) )) is null
	and m.postdate >= @FYStartDt

/*

-- This section should really go in the "Mark Onhands Processed" step of the DTS pkg

---------------------------------------------------
-- Mark items in Markdowns as having been handled, where BatchNo and ItemKey match
UPDATE Markdowns SET invenphysadj = @CurDateTime 
FROM Markdowns M
INNER JOIN Markdown_OnHand_Upload I on (
	LTRIM(RTRIM(M.BatchNo)) = LTRIM(RTRIM( SUBSTRING(I.IMPREF, 3, LEN(I.IMPREF)) ))
	AND
	LTRIM(RTRIM(M.ItemKey)) = LTRIM(RTRIM(I.IMPITM))
)
*/
GO
