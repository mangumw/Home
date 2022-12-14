USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spLoadMarkdownUpload]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLoadMarkdownUpload]
AS

BEGIN TRANSACTION
INSERT INTO MarkdownUpload 
			(
		      BatchNo
			, YearAdded
			, MonthAdded
			, DayAdded
			, StoreNo
			, Dept
			, MD_Code
			, TotalAmt
			)

SELECT BatchNo
	  		, Right(Year(PostDate),2)
			, Month(PostDate)
			, Day(PostDate)
			, StoreNo
			, Dept
			, 'NC' as MD_Code
			, Sum((NewPrice - OldPrice) * Qty) as TotalAmt
FROM Markdowns
WHERE Posted = 0 AND ApprovalUser <> 0
GROUP BY BatchNo, Right(Year(PostDate),2), Month(PostDate), Day(PostDate), StoreNo, Dept


	UPDATE MarkdownUpload
	SET MD_Code = 'MD'
	WHERE TotalAmt < 0

	UPDATE MarkdownUpload
	SET MD_Code = 'MU'
	WHERE TotalAmt > 0

	UPDATE MarkdownUpload
	SET TotalAmt = Abs(TotalAmt)
	COMMIT TRANSACTION
GO
