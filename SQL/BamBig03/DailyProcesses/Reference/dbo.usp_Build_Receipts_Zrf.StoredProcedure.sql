USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Receipts_Zrf]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Receipts_Zrf]
as
--
-- This is the build proc for the build of reference.dbo.ZRFRCVQ and reference.dbo.Receipt Tracking 
--
-- Declare Variables Needed   
--

declare @startdate smalldatetime
declare @startshort int
declare @fiscal_year int
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())

--
-- Get date range (YTD)
--
select @startdate = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = 1
select @startshort =  cast(CONVERT(varchar(20),@startdate,112) as INT)
--
-- Update Reference.dbo.Zrfrcvq
--

Delete from reference.dbo.zrfrcvq where RQDATE >= @startshort

insert into reference.dbo.zrfrcvq
select RQDATE, RQPONO, RQVNNO, RQITNO, RQCOST, RQSPRC, RQQTYP, RQQTYR, RQWHSE, 
convert(datetime, left(RQDATE,8)) as Newday
 from [BKL400].BKL400.AWBMODF.ZRFRCVQ where RQDATE >= @startshort

--
-- Update reference.dbo.Receipt_Tracking
--
delete from reference.dbo.Receipt_Tracking where Day_Date >= @startdate

insert into reference.dbo.receipt_tracking
select newday, rqpono, rqvnno, rqitno, rqwhse, rqcost, rqsprc, rqqtyp, rqqtyr 
from reference.dbo.zrfrcvq
where newday >= @startdate

GO
