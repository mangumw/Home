truncate table Staging.dbo.wrk_Card_Inventory
--
select	sku_number,
		sum(display_min) as display_min
into	#display_min
from	reference.dbo.item_display_min
group by sku_number

truncate table staging.dbo.wrk_inv_onhands_All
insert into staging.dbo.wrk_Inv_OnHands_All
select	sku_number,
		isnull(sum(on_hand),0) as On_Hand
from	reference.dbo.invcbl
group by sku_number

