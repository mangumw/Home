declare @seldate smalldatetime
select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()))
select @seldate = dateadd(dd,0,@seldate)
truncate table staging.dbo.wrk_Card_DCWTD
insert into staging.dbo.wrk_Card_DCWTD
select	t1.sku_number,
		isnull(sum(t2.item_quantity),0) as DCWTD_Units,
		isnull(sum(t2.Extended_Price),0) as DCWTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.detail_transaction_period t2
		on t2.sku_number = t1.sku_number
		and t2.store_number = 55
		and t2.day_date > @seldate
group by t1.sku_number