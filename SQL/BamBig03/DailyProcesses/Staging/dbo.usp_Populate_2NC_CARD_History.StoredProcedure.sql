USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_2NC_CARD_History]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Populate_2NC_CARD_History]
as
delete from DssData.dbo.CARD_2NC_History where day_date = staging.dbo.fn_dateonly(getdate())
--
insert into DssData.dbo.CARD_2NC_History
select	
		--'2022-02-06 00:00:00' as day_date,
		staging.dbo.fn_DateOnly(Getdate()) as day_date,
		SKU,
		DW_ISBN,
		Retail,
		OnHand_2NC,
		OnOrder_2NC,
		Warehouse_OnHand,
		Qty_OnOrder,
		Qty_OnBackorder
from DssData.dbo.CARD_2NC

 


GO
