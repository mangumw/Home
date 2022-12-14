USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Customer_Summary]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Customer_Summary]
as
declare @TYDay1 smalldatetime
declare @SelGCLU DateTime
declare @LYDay1 smalldatetime
declare @LYToday smalldatetime
declare @FY int
--
select @FY = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @TYDay1 = day_date from reference.dbo.calendar_dim where day_of_fiscal_year = 1 and fiscal_year = @FY
select @FY = @FY - 1
select @LYDay1 = day_date from reference.dbo.calendar_dim where day_of_fiscal_year = 1 and fiscal_year = @FY
select @LYToday = dateadd(yy,-1,staging.dbo.fn_DateOnly(GetDate()))
select @SelGCLU = @TYDay1
--
truncate table dssdata.dbo.Customer_Summary
--
-- First, build blank table from current card holders
--
insert into dssdata.dbo.Customer_Summary
select	mcustnum,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		NULL,
		Getdate(),
		Expdate1
from	dssdata.dbo.gclu
where	ExpDate1 > @SelGCLU
or		Expdate2 > @SelGCLU
or		ExpDate3 > @SelGCLU
--
select	staging.dbo.fn_leftpad(t1.customer_number,10) as Customer_Number,
		count(t1.Transaction_Number) as Num_Transactions,
		sum(t2.extended_price) as SLSD,
		sum(t2.item_quantity) as SLSU,
		sum(t2.extended_discount) as Discounts,
		avg(Extended_Price) as Avg_Transaction,
		0 as LY_Num,
		0 as LY_SLSD,
		0 as LY_SLSU,
		0 as LY_Discounts,
		0 as LY_Avg_Transactions,
		NULL as Latest_Purchase,
		staging.dbo.fn_DateOnly(Getdate()) as Last_Update
into	#TYCust
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_history t2
where	t1.day_date >= @TYDay1
and		t1.day_date <= staging.dbo.fn_dateonly(getdate())
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.register_nbr = t1.register_number
and		t2.transaction_nbr = t1.transaction_number
AND		t1.customer_number > 0
group by t1.customer_number
--
-- Update blank table with TY data
--
update dssdata.dbo.Customer_Summary
set		Num_Transactions = #TYCust.Num_Transactions,
		SLSD = #TYCust.SLSD,
		SLSU = #TYCust.SLSU,
		Discounts = #TYCust.Discounts,
		AVG_Transaction = #TYCust.AVG_Transaction
from	#TYCust
where	dssdata.dbo.Customer_Summary.Customer_Number = #TYCust.Customer_Number
--
-- Get LY Data
--
select	staging.dbo.fn_leftpad(t1.customer_number,10) as Customer_Number,
		count(t1.Transaction_Number) as LY_Num_Transactions,
		sum(t2.extended_price) as LY_SLSD,
		sum(t2.item_quantity) as LY_SLSU,
		sum(t2.extended_discount) as LY_Discounts,
		avg(Extended_Price) as LY_Avg_Transaction
into	#LYCust
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_history t2
where	t1.day_date >= @LYDay1
and		t1.day_date <= @LYToday
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.register_nbr = t1.register_number
and		t2.transaction_nbr = t1.transaction_number
and		t1.customer_number > 0
group by t1.customer_number
--
-- Update Blank Table with LY Data
--
update dssdata.dbo.Customer_Summary
set		LY_Num_Transactions = #LYCust.LY_Num_Transactions,
		LY_SLSD = #LYCust.LY_SLSD,
		LY_SLSU = #LYCust.LY_SLSU,
		LY_Discounts = #LYCust.LY_Discounts,
		LY_AVG_Transaction = #LYCust.LY_AVG_Transaction
from	#LYCust
where	dssdata.dbo.Customer_Summary.Customer_Number = #LYCust.Customer_Number
--	
select	staging.dbo.fn_leftPad(customer_number,10) as Customer_Number,
		max(day_date) as Last_Transaction
into	#LTrans
from	dssdata.dbo.header_transaction
where	day_date >= @LYDay1
group by Customer_Number
--
update dssdata.dbo.customer_summary
set		latest_purchase = Last_Transaction
from	#LTrans
where	#LTrans.Customer_Number = dssdata.dbo.customer_summary.customer_number

drop table #TYCust
drop table #LYCust
drop table #LTrans


GO
