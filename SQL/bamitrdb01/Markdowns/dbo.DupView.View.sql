USE [Markdowns]
GO
/****** Object:  View [dbo].[DupView]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DupView]
AS
SELECT     Category, Dept, ItemKey, Title, OldPrice, NewPrice, Qty, ReasonID, StoreNo
FROM         dbo.Markdowns
GO
