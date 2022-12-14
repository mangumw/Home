USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Reason_codes]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE procedure [dbo].[usp_rpt_Reason_codes] 
@StartDate smalldatetime,
@EndDate smalldatetime,
@Promo_Group varchar(10)
--



as
--
if @StartDate IS NULL
	select @StartDate = datepart(mm,getdate()) + '/01/' + datepart(yy,getdate())
if @enddate IS NULL
	select @EndDate = staging.dbo.fn_dateonly(getdate())
--
if @promo_Group = '<All>'
  select @promo_group = '%'
--



select	t1.Store_Number,
	t1.transaction_nbr,
	t1.Reason_Code,
	t1.extended_price,
	t1.extended_discount
	into	#step1
	from	dssdata.dbo.detail_transaction_history  t1
	where	t1.day_date >= @StartDate and day_date <= @EndDate 
	and		t1.Reason_Code <> ' '
	--and		t1.Reason_Code in (select Reason_Code from reference.dbo.Reason_Code_Dim )

--
select	t0.Store_Number,
		t0.Reason_code,
		t3.Description,
		t2.Store_Name as Store_Name,
		count(distinct cast(t0.store_number as varchar(3)) + cast(t0.transaction_nbr as varchar(10))) as Transactions,
		sum(t0.Extended_Price) as Tendered,
		abs(sum(t0.Extended_Discount)) as Discount,
		NULL as Avg_Per_Transaction
from	#step1 t0,
		Reference.dbo.Active_Stores t2,
		Reference.dbo.Reason_Code_Dim t3
where	t2.Store_Number = t0.Store_Number
and		t3.Reason_code = t0.Reason_code
group by t0.reason_code,t3.description,t0.store_number,t2.Store_Name
order by t0.Reason_Code,t0.Store_Number









GO
