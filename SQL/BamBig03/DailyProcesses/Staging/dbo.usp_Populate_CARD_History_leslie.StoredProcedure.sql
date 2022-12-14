USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_CARD_History_leslie]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Populate_CARD_History_leslie]
as
delete from card_history_leslie where day_date = staging.dbo.fn_dateonly(getdate()+3)
--
insert into CARD_History_leslie
select	1,
	staging.dbo.fn_DateOnly(Getdate()+3) as day_date,
		sku_number,
		ISBN,
		Retail,
		BAM_OnHand,
		Warehouse_OnHand,
		Qty_OnOrder,
		Qty_OnBackorder,
		Total_OnHand
from DssData.dbo.CARD

GO
