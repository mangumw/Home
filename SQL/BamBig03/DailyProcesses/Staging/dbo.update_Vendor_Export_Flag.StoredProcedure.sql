USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[update_Vendor_Export_Flag]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[update_Vendor_Export_Flag]
AS


update reference.dbo.Vendor_Export_Config set Sent = 0

GO
