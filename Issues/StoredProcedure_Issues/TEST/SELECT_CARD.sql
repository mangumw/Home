select	sku_number,
		sum(display_min) as display_min
into	#display_min
from	reference.dbo.item_display_min
group by sku_number
insert into Staging.dbo.wrk_Card_Inventory
select	reference.dbo.item_master.sku_number,
		Reference.dbo.ITBAL.WarehouseID,
		isnull(#display_min.Display_Min,0) as Store_Min,
		isnull(staging.dbo.wrk_inv_onhands.on_hand,0) as BAM_OnHand,
		Isnull(Reference.dbo.INVCBL.TrfOnOrder,0) as BAM_OnOrder,
		isnull(Reference.dbo.ITBAL.OnHand,0) AS Warehouse_OnHand, 
		isnull(Reference.dbo.ITBAL.OnPO,0) AS Qty_OnOrder, 
		isnull(Reference.dbo.ITBAL.OnBackOrder,0) AS Qty_OnBackorder, 
		isnull(Reference.dbo.ITBAL.InTransit,0) as InTransit,
		isnull(staging.dbo.wrk_card_wmbal.OnHand,0) as ReturnCenter_OnHand,
		case
			when (staging.dbo.wrk_inv_onhands.On_Hand + isnull(Reference.dbo.ITBAL.OnHand,0)) < 0
			then 0
		else
			isnull(staging.dbo.wrk_inv_onhands.On_Hand,0) + isnull(Reference.dbo.ITBAL.OnHand,0) 
		End AS Total_OnHand
from	reference.dbo.item_master 
		left join reference.dbo.invcbl
		on reference.dbo.invcbl.sku_number = reference.dbo.item_master.sku_number
		left join reference.dbo.itbal
		on reference.dbo.itbal.sku_number = reference.dbo.item_master.sku_number
		left join #display_min
		on #display_min.sku_number = reference.dbo.item_master.sku_number
		left join staging.dbo.wrk_inv_onhands
		on staging.dbo.wrk_inv_onhands.sku_number = reference.dbo.item_master.sku_number
		left join staging.dbo.wrk_card_wmbal on staging.dbo.wrk_card_wmbal.ISBN = reference.dbo.item_master.sku_text