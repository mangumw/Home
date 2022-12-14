USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Coupon_Receipts]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Coupon_Receipts]
as
--
select	t1.store_number, 
		count(t1.transaction_number) as Total_Trans
into	#tt1
from	dssdata.dbo.header_transaction t1
where	t1.day_date >= '9-28-2010'
and		t1.customer_number > 0
and		t1.transaction_amount >= 20.00
group by t1.store_number

select	t1.store_number, 
		count(t1.transaction_Code) as Redeemed
into	#tt2
from	dssdata.dbo.promotion_transactions t1
where	t1.day_date >= '9-28-2010'
and		t1.reason_code = 'IDS00465'
group by t1.store_number
select	t1.store_number, 
		count(t1.transaction_Code) as Redeemed_1221
into	#tt3
from	dssdata.dbo.promotion_transactions t1
where	t1.day_date >= '9-28-2010'
and		t1.reason_code = 'IDS01221'
group by t1.store_number

drop table ReportData.dbo.rpt_Coupon_Receipts
--
select	t1.Store_Number,
		t5.Store_Name,
		t1.Total_Trans,
		isnull(t2.Redeemed,0) as Redeemed,
		isnull(t3.Redeemed_1221,0) as redeemed_1221
into	ReportData.dbo.rpt_Coupon_Receipts
from	#tt1 t1 left join #tt2 t2
on		t2.store_number = t1.store_number
		left join #tt3 t3
on		t3.store_number = t1.store_number
		inner join reference.dbo.store_dim t5
on		t5.store_number = t1.store_number

drop table #tt1
drop table #tt2
drop table #tt3








GO
