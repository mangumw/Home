insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	staging.dbo.wrk_inv_onhands_dtl
group by sku_number