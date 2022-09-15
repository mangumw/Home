truncate table staging.dbo.wrk_inv_onhands_All
insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	reference.dbo.invcbl
group by sku_number