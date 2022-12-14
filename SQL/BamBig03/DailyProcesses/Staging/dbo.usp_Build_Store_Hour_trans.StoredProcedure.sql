USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Hour_trans]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Store_Hour_trans]
as
--
declare @seldate smalldatetime
declare @yd smalldatetime
declare @rowcnt int
declare @strsql nvarchar(1000)
--
declare @day_date smalldatetime
declare @store_number int
declare @trans_hour int
declare @trans_count int
--
select @yd = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
select @seldate = staging.dbo.fn_dateonly(dateadd(dd,-5,getdate()))
--
select @rowcnt = count(store_number) from dssdata.dbo.store_hour_trans where day_date = @yd
if @rowcnt = 0
INSERT INTO [DssData].[dbo].[Store_Hour_Trans]
           select @yd
           ,store_number
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0 from reference.dbo.active_stores
--
select	day_date,
		store_number,
		left(staging.dbo.fn_leftpad(cast(transaction_time as varchar(10)),6),2) as Trans_Hour,
		count(transaction_nbr) as Trans_count
into	#tmp_trans
from	dssdata.dbo.detail_transaction_period
where day_date >= @seldate
group by day_date,store_number,left(staging.dbo.fn_leftpad(cast(transaction_time as varchar(10)),6),2)
order by day_date,store_number,left(staging.dbo.fn_leftpad(cast(transaction_time as varchar(10)),6),2)
--
declare cur cursor for select day_date,Store_number,trans_hour,trans_count from #tmp_trans
open cur
fetch next from cur into @day_date,@Store_Number,@Trans_Hour,@Trans_Count
--
while @@fetch_status = 0
begin
select @strsql = 'Update dssdata.dbo.store_hour_trans set Hour_' + staging.dbo.fn_leftpad(cast(@trans_hour as varchar(2)),2) + '_trans = ' + cast(@trans_count as varchar(4)) + ' '
select @strsql = @strsql + 'where day_date = ' + '''' + convert(varchar(12),@day_date,1) + '''' + ' '
select @strsql = @strsql + 'and store_number = ' + cast(@store_number as varchar(3))
--
select @strsql
exec sp_executesql @strsql
--
fetch next from cur into @day_date,@Store_Number,@Trans_Hour,@Trans_Count
end
close cur
deallocate cur

--drop table #tmp_trans
--select * from #tmp_trans
--
GO
