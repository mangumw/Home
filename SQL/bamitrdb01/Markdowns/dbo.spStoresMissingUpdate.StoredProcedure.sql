USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spStoresMissingUpdate]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spStoresMissingUpdate]
AS
	DECLARE @DaysPrior int
	SET @DaysPrior = (SELECT DataValue FROM AppData WHERE DataName = 'DaysMissedMarkdowns')
	SELECT DISTINCT 'mgr' + Cast(storeno as varchar(4)) + '@booksamillion.com' AS StoreEmail FROM markdowns WHERE storeno NOT IN
		(SELECT distinct storeno FROM markdowns where [DateAdd] > DateAdd(day, @DaysPrior, GetDate()))
GO
