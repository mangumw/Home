USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_CFFP]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_build_CFFP]
as
drop table reference.dbo.POHED
drop table reference.dbo.PODET

Select * INTO reference.dbo.CFFPOHeader
from reference.dbo.POHED
WHERE Vendor_number = 'CFF'
 
Select * INTO reference.dbo.CFFPODetail
from reference.dbo.PODET
WHERE Vendor_Number = 'CFF'
GO
