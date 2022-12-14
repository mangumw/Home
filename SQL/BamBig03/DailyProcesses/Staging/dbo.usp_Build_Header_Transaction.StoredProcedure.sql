USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Header_Transaction]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Header_Transaction]
as 
declare @mindate smalldatetime
declare @maxdate smalldatetime
--
select @mindate = staging.dbo.fn_intToDate(min(csdate)) from staging.dbo.header_transaction_raw
select @maxdate = staging.dbo.fn_intToDate(max(csdate)) from staging.dbo.header_transaction_raw
delete from dssdata.dbo.header_transaction where day_date >= @mindate and day_date <= @maxdate
--
insert into dssdata.dbo.Header_Transaction
select	staging.dbo.fn_intToDate(csdate) as day_date,
		csstor,
		csreg#,
		cstrn#,
		csroll,
		cstime,
		csttyp,
		cstamt,
		cststs,
		cshlte,
		cscsh#,
		cstil,
		csslpr,
		csatyp,
		csacct,
		cssrsn,
		cssosp,
		cssost,
		cscust,
		staging.dbo.fn_dateonly(getdate()) as Load_Date
from	staging.dbo.Header_Transaction_Raw
where csstor <>'54'
GO
