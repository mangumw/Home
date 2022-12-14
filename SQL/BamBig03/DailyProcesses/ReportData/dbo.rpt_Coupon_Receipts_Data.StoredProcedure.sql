USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Coupon_Receipts_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Coupon_Receipts_Data]
@Start_Date sql_variant,
@End_Date sql_variant
as
--
if @Start_Date IS NULL
  select @Start_Date = staging.dbo.fn_Last_Saturday(getdate())
if @End_Date IS NULL
  select @End_Date = staging.dbo.fn_DateOnly(Getdate())
--
select	t1.store_number, 
		count(t1.transaction_number) as Total_Trans
into	staging.dbo.Receipts1
from	dssdata.dbo.header_transaction t1
where	t1.day_date >= @Start_Date and t1.day_date <= @End_Date
and		t1.customer_number > 0
and		t1.transaction_amount >= 20.00
group by t1.store_number

select	t1.store_number, 
		count(t1.transaction_Code) as Redeemed_465
into	staging.dbo.receipts2
from	dssdata.dbo.promotion_transactions t1
where	t1.day_date >= @Start_Date and t1.day_date <= @end_date
and		t1.reason_code = 'IDS00465'
group by t1.store_number
select	t1.store_number, 
		count(t1.transaction_Code) as Redeemed_1221
into	staging.dbo.receipts3
from	dssdata.dbo.promotion_transactions t1
where	t1.day_date >= @Start_Date and t1.day_date <= @end_date
and		t1.reason_code = 'TDS01221'
group by t1.store_number

drop table ReportData.dbo.rpt_Coupon_Receipts
--
select	t1.Store_Number,
		t5.Store_Name,
		t1.Total_Trans,
		isnull(t2.Redeemed_465,0) as Redeemed_465,
		isnull(t3.Redeemed_1221,0) as redeemed_1221
--into	ReportData.dbo.rpt_Coupon_Receipts
from	staging.dbo.receipts1 t1 left join staging.dbo.receipts2 t2
on		t2.store_number = t1.store_number
		left join staging.dbo.receipts3 t3
on		t3.store_number = t1.store_number
		inner join reference.dbo.store_dim t5
on		t5.store_number = t1.store_number

--drop table staging.dbo.receipts1
--drop table staging.dbo.receipts2
--drop table staging.dbo.receipts3





GO
