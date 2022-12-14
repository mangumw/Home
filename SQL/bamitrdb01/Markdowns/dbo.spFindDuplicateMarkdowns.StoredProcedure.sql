USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spFindDuplicateMarkdowns]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spFindDuplicateMarkdowns] AS
SELECT * FROM DupView
GROUP BY Category, Dept, ItemKey, Title, OldPrice, NewPrice, Qty, ReasonID, StoreNo
HAVING ((Count(Category)>1) AND (Count(Dept)>1) AND (Count(ItemKey)>1) AND (Count(Title)>1)
 AND (Count(OldPrice)>1) AND (Count(NewPrice)>1) AND (Count(Qty)>1) AND (Count(ReasonID)>1)
 AND (Count(StoreNo)>1))
GO
