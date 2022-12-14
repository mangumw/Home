USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spMarkdownDelete]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spMarkdownDelete]
	@BatchNo int
AS
	DECLARE @ReturnValue int
	BEGIN TRANSACTION
	UPDATE Markdowns SET DateLastMod = GetDate() WHERE BatchNo = @BatchNo
	INSERT INTO MarkdownDelete
		SELECT * FROM Markdowns WHERE BatchNo = @BatchNo
	DELETE FROM Markdowns WHERE BatchNo = @BatchNo
	SET @ReturnValue = 1   --success
	COMMIT TRANSACTION
	RETURN @ReturnValue
GO
