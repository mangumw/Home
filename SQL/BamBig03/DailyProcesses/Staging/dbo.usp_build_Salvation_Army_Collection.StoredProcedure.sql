USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_Salvation_Army_Collection]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_Salvation_Army_Collection]
as
declare @sd smalldatetime
select @sd = min(staging.dbo.fn_intToDate(csdate)) from staging.dbo.detail_transaction_period_raw
--
delete from dssdata.dbo.salvation_army_collection
where day_date >= @sd
--
insert into dssdata.dbo.salvation_army_collection
select	staging.dbo.fn_IntToDate(csdate),
		csstor,
		sum(csqty) as SLSU,
		sum(csexpr) as SLSD
from	staging.dbo.detail_transaction_period_raw
where	cssku# = 2023733
group by csdate,csstor


GO
