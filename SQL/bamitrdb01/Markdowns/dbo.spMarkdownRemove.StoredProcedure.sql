USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spMarkdownRemove]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spMarkdownRemove]
	@BatchNo int,
	@DateAdd datetime output
AS
	DECLARE @ReturnValue int
	SET @DateAdd = (SELECT Top 1 DateAdd FROM Markdowns WHERE BatchNo = @BatchNo)
	DELETE FROM Markdowns WHERE BatchNo = @BatchNo
	SET @ReturnValue = 1   --success
	RETURN @ReturnValue
GO
