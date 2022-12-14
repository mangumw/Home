USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Type_I_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Type_I_Sales]
as
--
truncate table ReportData.dbo.Type_I_Sales
insert into ReportData.dbo.Type_I_Sales
select	t1.sku_number,
		t1.title,
		t1.Pub_Code,
		t1.VIN,
		t1.Sr_Buyer,
		t1.Buyer,
		t1.BAM_OnHand,
		t1.BAM_OnOrder,
		t1.Warehouse_OnHand,
		t1.Qty_OnOrder,
		0 as Sold_Stores,
		sum(t2.Wk1_SLSU) as Wk1_SLSU,
		sum(t2.Wk2_SLSU) as Wk2_SLSU,		
		sum(t2.Wk3_SLSU) as Wk3_SLSU,		
		sum(t2.Wk4_SLSU) as Wk4_SLSU,		
		sum(t2.Wk5_SLSU) as Wk5_SLSU,
		sum(t2.Wk6_SLSU) as Wk6_SLSU,
		sum(t2.Wk7_SLSU) as Wk7_SLSU,
		sum(t2.Wk8_SLSU) as Wk8_SLSU
from	dssdata.dbo.card t1,
		reference.dbo.invbal t2
where	t1.sku_type = 'I'
and		t2.sku_number = t1.sku_number
and		t2.Wk1_SLSU > 5
group by t1.sku_number,
		t1.title,
		t1.Pub_Code,
		t1.VIN,
		t1.Sr_Buyer,
		t1.Buyer,
		t1.BAM_OnHand,
		t1.BAM_OnOrder,
		t1.Warehouse_OnHand,
		t1.Qty_OnOrder,
		t1.Week1Units
order by t1.Week1Units
--
select	t1.sku_number,
		count(t2.store_number) as Stores
into	#sls1
from	ReportData.dbo.Type_I_Sales t1,
		reference.dbo.invbal t2
where	t2.sku_number = t1.sku_number
and		t2.Wk1_SLSU > 5
Group by t1.sku_number
--
update	ReportData.dbo.Type_I_Sales
set		Sold_Stores = #sls1.Stores
from	#sls1
where	#sls1.sku_number = ReportData.dbo.Type_I_Sales.sku_number

GO
