USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_MFM]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_build_MFM]
as

declare @seldate smalldatetime
select @seldate = min(tdate) from staging.dbo.wrk_MFM
select @seldate = staging.dbo.fn_DateOnly(dateadd(dd,1,@seldate))

truncate table staging.dbo.wrk_mfm

insert into staging.dbo.wrk_mfm
select *
from OPENQUERY(OFFERS, 'SELECT o.tdate,o.store,s.fieldvalue
FROM offers o left join subofferdata s
on o.requestid = s.requestid and s.fieldname = ''Vendor ID''
WHERE o.tdate >= date_sub(now(), interval 7 day) ')


delete from reference.dbo.MFM where tdate >= @seldate
insert into reference.dbo.MFM
select * from staging.dbo.wrk_MFM where tdate >= @seldate

GO
