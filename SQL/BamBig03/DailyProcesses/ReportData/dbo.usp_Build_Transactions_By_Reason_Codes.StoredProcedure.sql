USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Transactions_By_Reason_Codes]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Transactions_By_Reason_Codes]
as
declare @SD smalldatetime
declare @ED smalldatetime
select @ED = staging.dbo.fn_Last_Saturday(getdate())
select @sD = dateadd(ww,-1,@ED)
--
-- Get transaction key info for transactions with reason codes
--
truncate table staging.dbo.wrk_reason_code_trans
insert into staging.dbo.wrk_reason_code_trans
select	t2.Reason_Code,
        t2.description,
		t1.day_date,
		t1.Store_Number,
		t3.store_name as Store_Name,
		t1.Register_Nbr,
		t1.Transaction_Nbr,
		t4.Transaction_Amount
from	dssdata.dbo.detail_transaction_period t1,
		reference.dbo.reason_code_dim t2,
		reference.dbo.active_stores t3,
		dssdata.dbo.header_transaction t4
where	t1.reason_code = t2.reason_code
and		t3.store_number = t1.store_number
and		t1.day_date >= @SD
and		t1.day_date <= @ED
and		t4.day_date = t1.day_date
and		t4.store_number = t1.store_number
and		t4.transaction_number = t1.transaction_nbr		
and		t4.register_number = t1.register_nbr
order by Reason_Code, Day_Date, Store_Number
--
-- Get detail_information for all items in above transactions
--
truncate table Reportdata.dbo.Transactions_By_Reason_Code
--
insert into Reportdata.dbo.Transactions_By_Reason_Code
select	t1.Reason_Code,
        t1.description,
		t1.Day_Date,
		t1.Store_Number,
		t1.Store_Name,
		t1.Register_Nbr,
		t1.Transaction_Nbr,
		t1.Transaction_Amount,
		sum(t2.Unit_Retail) as Unit_Retail,
		sum(t2.Extended_Price) as Extended_Price,
		sum(t2.Extended_Discount) as Extended_Discount
from	staging.dbo.wrk_reason_code_trans t1,
		Dssdata.dbo.detail_transaction_period t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.register_nbr = t1.register_nbr
and		t2.transaction_nbr = t1.transaction_nbr
and		t2.sku_number is not null
group by t1.Reason_Code,t1.description,t1.Day_Date,t1.Store_Number,t1.Store_Name,
		t1.Register_Nbr,t1.Transaction_Nbr,t1.Transaction_Amount
order by t1.Reason_code, t1.day_date, t1.store_number, t1.transaction_nbr



GO
