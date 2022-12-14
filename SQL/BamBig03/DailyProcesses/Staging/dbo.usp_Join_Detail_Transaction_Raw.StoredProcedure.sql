USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Join_Detail_Transaction_Raw]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Join_Detail_Transaction_Raw] 
AS
begin

declare @fiscal_week int
declare @fiscal_year int
declare @week_start smalldatetime
declare @week_end smalldatetime
declare @week_start_int int
declare @week_end_int int
declare @mindate smalldatetime
declare @Start_Date_int int
declare @Start_Date smalldatetime
--
select @Start_Date_int = min(csdate) from staging.dbo.detail_transaction_period_raw
select @Start_Date = staging.dbo.fn_IntToDate(@Start_Date_Int)
select @fiscal_week = fiscal_year_week from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(getdate())
select @fiscal_year = fiscal_year from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(getdate())
select @week_start = day_date from Reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_year_week = @fiscal_week - 1 and day_of_week_number = 1
select @Week_end = dateadd(dd,6,@week_start)
select @week_start_int = dbo.fn_datetoint(@week_start)
select @week_end_int = dbo.fn_datetoint(@week_end)
select @mindate = staging.dbo.fn_intToDate(min(csdate)) from staging.dbo.detail_transaction_period_raw

declare @rundate varchar(20)
select @rundate = left(getdate(),11) + ' 00:00:00'
--
truncate table DSSDATA.dbo.detail_transaction_period
--
insert into DSSDATA.dbo.Detail_Transaction_Period
select 
	dbo.fn_IntToDate(CSDATE) as day_date,
	t1.CSSTOR as Store_Number,
	t1.[CSREG#] as register_nbr,
	t1.[CSTRN#] as transaction_nbr,
	t1.[CSSEQ#] as sequence_number,
	t1.[CSDTYP] as transaction_code,
	t1.CSTIME as transaction_time,
	t1.cscsh# as Cashier_nbr,
	case t1.[CSSKU#] 
       when 0 then NULL
       else t1.[cssku#]
    end as sku_number,
	t2.isbn as ISBN,
	t1.CSQTY as item_quantity,
	t1.CSRETL as unit_retail,
	t1.CSCOST as unit_cost,
	t1.CSEXPR as extended_price,
	t1.CSEXDS as extended_Discount,
	case t1.CSPOVR
	  when 'P' then 'Y'
	  else 'N'
	end as price_override,
	t1.CSUPC# as UPC_Number,
	t1.CSRGPR as unit_regular_price,
	t1.CSRSNC as Reason_Code,
	getdate() as load_date,
	t1.CEPDPT
    from Staging.dbo.Detail_Transaction_Period_Raw t1 
left join Reference.dbo.item_master t2 on
t2.sku_number = cast(t1.[CSSKU#] as bigint)
where csdtyp IN ('01', '02', '03', '04', '11', '14', '22', '31', '53', '85', '86','VS')
and csstor <>'54'

delete from DSSDATA.dbo.Club_Card_Activity where day_date >= @Start_Date
--
insert into  DSSDATA.dbo.Club_Card_Activity
SELECT	staging.dbo.fn_IntToDate(t1.csdate)
		,t1.CSSTOR
		,t1.CSREG#
		,t1.CSTRN#
		,t1.CSSEQ#
		,t1.CSDTYP
		,t1.CSTIME
		,t2.Customer_Number
		,t3.MFNAME
		,t3.MLName
		,t3.MCompany
		,t3.MCreateDate
		,t3.ExpDate1
		,t3.ExpDate2
		,t3.ExpDate3
		,t3.XLastModDate
		,t3.MSpecial
		,t3.PClientType
		,t1.CSRETL
		,GetDate()
FROM	staging.dbo.Detail_Transaction_Period_Raw t1,
		dssdata.dbo.header_transaction t2,
		dssdata.dbo.gclu t3
where	t2.day_date = staging.dbo.fn_IntToDate(t1.CSDATE)
and		t2.store_number = t1.CSSTOR
and		t2.transaction_number = t1.CSTRN#
and		t2.register_number = t1.CSREG#
and		t1.CSDTYP = 'MC'
and		t3.MCustNum = t2.Customer_Number
--

end


GO
