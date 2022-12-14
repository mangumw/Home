USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spFirstDayThisWeek]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spFirstDayThisWeek]
AS
	declare @fiscweek tinyint
	declare @fiscyear smallint
	SELECT @fiscweek = weekfiscyear, @fiscyear = fiscyear
	 FROM BAMITR05.MiscSales.dbo.FiscCal
	 WHERE caldate Between DateAdd(d, -8, GETDATE()) and DateAdd(d, -7, GETDATE())
	select max(caldate) + 1 from miscsales.dbo.fisccal where weekfiscyear = @fiscweek and fiscyear = @fiscyear
GO
