USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_CARD_History]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Populate_CARD_History]
as
delete from dssdata.dbo.card_history where day_date = staging.dbo.fn_dateonly(getdate())
--
insert into DssData.dbo.CARD_History
select	
		1,
		--'2022-02-06 00:00:00' as day_Date,
		staging.dbo.fn_DateOnly(Getdate()) as day_date,
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
