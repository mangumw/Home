update Staging.dbo.wrk_Card_Inventory
set Store_Min = (select isnull(sum(Display_Min),0) from reference.dbo.item_display_min
				where reference.dbo.item_display_min.sku_number = Staging.dbo.wrk_Card_Inventory.sku_number)
where Store_Min = 0