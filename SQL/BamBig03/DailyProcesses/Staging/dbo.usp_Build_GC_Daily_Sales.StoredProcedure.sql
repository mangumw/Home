USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_GC_Daily_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_GC_Daily_Sales]
as
declare @sd smalldatetime
select @sd = min(staging.dbo.fn_IntToDate(CSDATE)) from staging.dbo.detail_transaction_Period_Raw
--
delete from dssdata.dbo.GC_Daily_Sales where day_date >= @sd
--
insert into dssdata.dbo.GC_Daily_Sales
select	staging.dbo.fn_IntToDate(csdate),
		t1.csstor,
		t2.isbn,
		t1.cssku#,
		sum(t1.csqty) as SLSU,
		sum(t1.csexpr) as SLSD
from	Staging.dbo.detail_transaction_period_Raw t1,
		reference.dbo.item_master t2
where	t1.cssku# = t2.sku_number
and		t2.coordinate_group in ('GFTCD','GCOLD')
group by staging.dbo.fn_IntToDate(csdate),t1.csstor,t2.isbn,t1.cssku#

GO
