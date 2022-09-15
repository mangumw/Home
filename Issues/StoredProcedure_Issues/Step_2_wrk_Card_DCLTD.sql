truncate table staging.dbo.wrk_Card_DCLTD
insert into staging.dbo.wrk_Card_DCLTD
(	   [sku_number]
      ,[DCLTD_Units]
      ,[DCLTD_Dollars]
)
select	t1.sku_number,
		ISNULL(sum(t2.current_Units),0) as DCLTD_Units,
		ISNULL(sum(t2.Current_Dollars),0.00) as DCLTD_Dollars
from	reference.dbo.item_master t1 
		left join dssdata.dbo.internet_weekly_sales t2
		on t2.sku_number = t1.sku_number
where t1.sku_number is not null
--AND t2.current_Units != 0
--AND t2.Current_Dollars != 0.00
group by t1.sku_number