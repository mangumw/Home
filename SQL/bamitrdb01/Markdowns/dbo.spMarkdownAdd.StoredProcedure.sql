USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spMarkdownAdd]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spMarkdownAdd]
	(
	@Category varchar(10),
	@Dept smallint,
	@ItemKey varchar(13) = NULL,
	@Title varchar(35),
	@OldPrice smallmoney,
	@NewPrice smallmoney,
	@Qty smallint,
	@Reason tinyint,
	@StoreNo smallint,
	@UserName varchar(30),
	@Validated tinyint,
	@BatchNo int,
	@LinePos tinyint,
	@Edit int,
	@DateAdd datetime,
	@PostDate datetime,
	@OrigOldPrice smallmoney
	)
AS
	DECLARE @NextKey int
	DECLARE @ReturnValue int
	DECLARE @EditDate datetime
	SET @NextKey = (SELECT Max(MarkdownID) + 1 AS NewKey FROM Markdowns)
	IF (@NextKey < 1 or @NextKey Is NULL)
		SET @NextKey = 1
	IF (@Edit > 0)
		SET @EditDate = GetDate()
	ELSE
		BEGIN
			SET @EditDate = NULL
			SET @DateAdd = GetDate()
		END
	--Set OrigOldPrice to zero if it matches the OldPrice passed in, otherwise leave as is to show original old price as loaded to page vs. typed Old Price
	IF (@OldPrice = @OrigOldPrice)
		SET @OrigOldPrice = 0
	INSERT INTO Markdowns
	(MarkdownID, BatchNo, Category, Dept, ItemKey, Title, OldPrice, NewPrice, 
		Qty, ReasonID, DateAdd, StoreNo, UserName, Validated, ApprovalUser, Posted, 
		LinePos, DateLastMod, PostDate, InvenPhysAdj, OrigOldPrice
	)
	VALUES (@NextKey, @BatchNo, @Category, @Dept, @ItemKey, @Title, @OldPrice, @NewPrice,
		@Qty, @Reason, @DateAdd, @StoreNo, @UserName, @Validated, 0, 0, 
		@LinePos, @EditDate, @PostDate, null, @OrigOldPrice)
	SET @ReturnValue = @NextKey   --success
	RETURN @ReturnValue
GO
