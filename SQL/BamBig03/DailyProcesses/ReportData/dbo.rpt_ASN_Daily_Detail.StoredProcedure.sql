USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_ASN_Daily_Detail]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_ASN_Daily_Detail]
as
select	t1.ASN_Date,
		t1.Order_Date as ASN_Order_Date,		
		t2.Due_Date,
		datepart(month,t2.due_date) as Due_Month,
		datepart(month,t1.ship_date) as ship_Month,
		t1.Ship_Date,
		DateDiff(day,t2.Due_Date,t1.Ship_Date) as Interval,
		t1.PO_Number,
		t3.Pub_Code,
		t3.Sr_Buyer,
		t3.Buyer,
		t1.ISBN,
		t3.Title,
		t3.Author,
		sum(t2.Order_Quantity) as Order_Quantity,
		t1.Retail_Price,
		sum(t2.Order_Quantity) * t1.Retail_Price as Extended_Retail,
		sum(t1.shipped_qty) as Shipped_Qty,
		sum(t1.received_qty) as Received_Qty
into	#tmp1
from	Reference.dbo.ZRFASNR t1 inner join Reference.dbo.PODET t2
		on t2.PO_Number = t1.PO_Number
		and t2.isbn = t1.isbn inner join Dssdata.dbo.CARD t3
		on t3.isbn = t1.isbn
where	t1.ASN_Date = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
and		datepart(year,t2.due_date) < 2010
group by t1.PO_Number,t1.ISBN,t1.asn_date,t1.Order_Date,t2.Due_Date,
		t1.Ship_Date,
		t3.Pub_Code,
		t3.Sr_Buyer,
		t3.Buyer,
		t3.Title,
		t3.Author,
		t1.retail_price

select	ASN_Date,
		ASN_Order_Date,
		Due_Date,		
		Ship_Date,
		PO_Number,
		Pub_Code,
		Sr_Buyer,
		Buyer,
		ISBN,
		Title,
		Author,
		Order_Quantity,
		Retail_Price,
		Extended_Retail,
		shipped_qty,
		received_qty
from	#tmp1
where	ship_date>due_date or ship_month <> due_month
order by sr_buyer,buyer,pub_code




GO
