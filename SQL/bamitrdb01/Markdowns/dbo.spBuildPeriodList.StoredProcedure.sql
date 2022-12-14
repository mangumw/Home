USE [Markdowns]
GO
/****** Object:  StoredProcedure [dbo].[spBuildPeriodList]    Script Date: 08/23/2022 14:30:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spBuildPeriodList]
AS
	DECLARE @FirstDate datetime
	DECLARE @LastDate datetime
	SELECT @FirstDate = (SELECT min(caldate) FROM BAMITR05.MiscSales.dbo.FiscCal WHERE caldate Between DateAdd(yy, -1, GETDATE()) and GETDATE())
	SELECT @LastDate = (SELECT max(caldate) FROM BAMITR05.MiscSales.dbo.FiscCal WHERE caldate Between DateAdd(yy, -1, GETDATE()) and GETDATE())
	SELECT DISTINCT FiscPeriod, FiscYear FROM BAMITR05.MiscSales.dbo.FiscCal WHERE caldate Between @FirstDate and @LastDate
	  ORDER BY fiscyear DESC, fiscperiod DESC
GO
