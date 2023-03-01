USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_IAXRF]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[usp_Build_IAXRF]
as

Truncate table reference.dbo.IAXRF

Insert into reference.dbo.IAXRF
Select * from BKL400.BKL400.APLUS2FAW.IAXRF
GO
