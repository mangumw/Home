truncate table staging.dbo.wrk_Card_LTD
insert into staging.dbo.wrk_Card_LTD
select	t1.sku_number,
		LifeTodateUnits as LTD_Units,
		LifeToDateDollars as LTD_Dollars
from	reference.dbo.item_master t1 
		left join reference.dbo.invcbl t2
		on t2.sku_number = t1.sku_number