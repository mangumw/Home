USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_ASN_Closed_PO]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_ASN_Closed_PO]
as
--
drop table Reportdata.dbo.rpt_ASN_Closed_PO
--
select	t1.PO_Number,
		t3.Pub_Code,
		t3.Sr_Buyer,
		t3.Buyer,
		t1.ISBN,
		t3.Title,
		t3.Author,
		t1.Order_Date as ASN_Order_Date,		
		t2.Due_Date,
		t4.Last_Change_Date as Close_Date,
		t2.Order_Amount,
		t4.Number_Of_Items as Received_Amount,
		t3.Warehouse_OnHand,
		t3.Total_OnHand,
		t3.Qty_OnOrder
--into	ReportData.dbo.rpt.ASN_Closed_PO
from	Reference.dbo.ZRFASNR t1 inner join Reference.dbo.PODET t2
		on t2.PO_Number = t1.PO_Number
		and t2.isbn = t1.isbn inner join DssData.dbo.CARD t3
		on t3.isbn = t1.isbn
		inner join reference.dbo.POHED t4
		on t4.Order_Number = t2.Order_ID
		and t4.Company_Number = t2.Company_Number
where	t1.ASN_Date = staging.dbo.fn_dateonly(dateadd(ww,-1,getdate()))
and		datepart(year,t2.due_date) < 2010
and		t4.Status = 'C'
--

GO
