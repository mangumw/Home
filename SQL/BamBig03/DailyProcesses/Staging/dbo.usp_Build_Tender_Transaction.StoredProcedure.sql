USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Tender_Transaction]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Tender_Transaction]
as 
declare @mindate smalldatetime
declare @maxdate smalldatetime
--
select @mindate = staging.dbo.fn_intToDate(min(csdate)) from staging.dbo.Tender_transaction_raw
select @maxdate = staging.dbo.fn_intToDate(max(csdate)) from staging.dbo.Tender_transaction_raw
delete from dssdata.dbo.tender_transaction where day_date >= @mindate and day_date <= @maxdate
--
insert into dssdata.dbo.Tender_Transaction
select	staging.dbo.fn_intToDate(csdate) as day_date,
		Store_number,
		Register_Number,
		Roll_Over,
		Transaction_number,
		Sequence_Number,		
		Tender_Type,
		Tender_Amount,
		staging.dbo.fn_dateonly(getdate()) as Load_Date
from	staging.dbo.Tender_Transaction_Raw
where store_number <> '54'
GO
