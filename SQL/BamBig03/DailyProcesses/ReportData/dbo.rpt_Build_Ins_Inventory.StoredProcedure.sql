USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Build_Ins_Inventory]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Build_Ins_Inventory]
as
truncate table ReportData.dbo.rpt_Ins_Inventory
insert into ReportData.dbo.rpt_Ins_Inventory
select	t1.sr_buyer,
		t1.buyer,
		t1.pub_code,
		t1.ISBN,
		t1.Dept_Name,
		t1.SDept_Name,
		t1.Title,
		t1.Week1Units,
		t1.BAM_WOS,
		t1.Sell_Thru,
		t1.Bookscan_Rank,
		t1.Internet_Rank,
		t1.BAM_OnHand,
		t1.Warehouse_OnHand-InTransit as AWBC_Net_Available,
		t1.Qty_OnOrder
from	dssdata.dbo.card t1
where	t1.sku_type <> 'P'
and		(t1.BAM_WOS > 0 and t1.BAM_WOS < 4 and t1.Week1Units > 20)
or		(((t1.sell_thru * 100) > 15) and t1.Week1Units > 20)
or    ((t1.Bookscan_Rank < 1001 and t1.bookscan_Rank > 0) and t1.Stocked_Stores < 10)
or    ((t1.Internet_Rank < 101 and t1.Internet_Rank > 0) and t1.Stocked_Stores < 10)
order by sr_buyer,buyer,Week1Units desc






GO
