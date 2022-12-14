USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Store_Supplies_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Store_Supplies_Report]
as
declare @sd smalldatetime
declare @ed smalldatetime
--
select @ed = staging.dbo.fn_Last_Saturday(getdate())
select @sd = dateadd(dd,-6,@ed)
--
select	t1.Customer_Number,
		t3.Store_Name,
		t1.Order_Number,
		t1.Entry_Date,
		t2.Item_Number,
		t2.Item_Desc_1,
		t2.Qty_Ordered,
		t2.Qty_Shipped,
		t2.List_Price,
		t2.Actual_Sell_Price,
		t2.Qty_Ordered * t2.Actual_Sell_Price as Line_Price
from	reference.dbo.HSHED t1, reference.dbo.HSDET t2, reference.dbo.active_stores t3
where	t1.Entry_Date >= staging.dbo.fn_DateToLongDate(@SD)
and		t1.Entry_Date <= staging.dbo.fn_DateToLongDate(@ED)
and		t2.item_class in ('51','52','53','54','57','61') 
--and		t1.Customer_Number > 100 and t1.Customer_Number < 970
and		t2.Order_Number = t1.Order_Number
and		t3.store_number = t1.Customer_Number
Union All
select	t1.Customer_Number,
		t3.Store_Name,
		t1.Order_Number,
		t1.Entry_Date,
		t2.Item_Number,
		t2.Item_Desc_1,
		t2.Qty_Ordered,
		t2.Qty_Shipped,
		t2.List_Price,
		t2.Actual_Sell_Price,
		t2.Qty_Ordered * t2.Actual_Sell_Price as Line_Price
from	reference.dbo.ORHED t1, reference.dbo.ORDET t2, Reference.dbo.active_Stores t3
where	t1.Entry_Date >= staging.dbo.fn_DateToInt(@SD)
and		t1.Entry_Date <= staging.dbo.fn_DateToInt(@ED)
and		t2.item_class in ('51','52','53','54','57','61') 
--and		t2.Item_SubClass = 'SS'
--and		t1.Customer_Number > 100 and t1.Customer_Number < 970
and		t2.Order_Number = t1.Order_Number
and		t3.Store_Number = t1.Customer_Number
order by t1.Customer_Number,t1.Entry_Date




GO
