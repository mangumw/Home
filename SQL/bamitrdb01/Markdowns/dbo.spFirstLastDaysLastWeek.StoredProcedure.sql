USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spFirstLastDaysLastWeek]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spFirstLastDaysLastWeek]
AS
	declare @fiscweek tinyint
	declare @fiscyear smallint
	SELECT @fiscweek = weekfiscyear, @fiscyear = fiscyear FROM BAMITR05.MiscSales.dbo.FiscCal
	 WHERE caldate Between DateAdd(d, -8, GETDATE()) and DATEADD(d, -7, GETDATE())
	select min(caldate), max(caldate) from miscsales.dbo.fisccal where weekfiscyear = @fiscweek and fiscyear = @fiscyear
GO
