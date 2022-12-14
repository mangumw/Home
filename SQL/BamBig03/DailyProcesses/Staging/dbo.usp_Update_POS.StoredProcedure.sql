USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_POS]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Update_POS]
as
select t1.PO_Number,
		t1.item_number,
		sum(t2.Receipt_Qty) as Qty_Received
into	#POS_UPD
from	Reference.dbo.POS t1,
		reference.dbo.RCPT t2
where	t2.PO_Number = t1.PO_Number
and		t2.Item_Number = t1.item_number
group by t1.PO_Number,t1.Item_Number
order by t1.PO_Number
update reference.dbo.pos set pos.Qty_Received = #POS_UPD.Qty_Received
from #POS_UPD
where POS.PO_Number = #POS_UPD.PO_Number
and POS.Item_Number = #POS_UPD.Item_Number

GO
