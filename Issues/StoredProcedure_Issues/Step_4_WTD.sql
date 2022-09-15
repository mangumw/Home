declare @year int
declare @week int
declare @seldate smalldatetime

select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)

--select @seldate
--

truncate table staging.dbo.wrk_Card_WTD
insert into
 staging.dbo.wrk_Card_WTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as WTD_Units,
		isnull(sum(t2.Extended_Price),0) as WTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and ((t2.Store_Number BETWEEN 100 AND 980)
		or (t2.store_number BETWEEN 2099 and 2999))
		and t2.day_date > @seldate
group by t1.sku_number