USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Join_Detail_Transaction_Rebuild]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Join_Detail_Transaction_Rebuild] 
AS
begin

--declare @fiscal_week int
--declare @fiscal_year int
--declare @week_start smalldatetime
--declare @week_end smalldatetime
--declare @week_start_int int
--declare @week_end_int int
--
--select @fiscal_week = fiscal_year_week from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(getdate())
--select @fiscal_year = fiscal_year from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(getdate())
--select @week_start = day_date from Reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_year_week = @fiscal_week - 1 and day_of_week_number = 1
--select @Week_end = dateadd(dd,6,@week_start)
--select @week_start_int = dbo.fn_datetoint(@week_start)
--select @week_end_int = dbo.fn_datetoint(@week_end)

declare @rundate varchar(20)
select @rundate = left(getdate(),11) + ' 00:00:00'
--truncate table Staging.dbo.Detail_Transaction_Rebuild
insert into Staging.dbo.Detail_Transaction_Rebuild
select 
	dbo.fn_IntToDate(CSDATE) as day_date,
	t1.CSSTOR as Store_Number,
	t1.[CSREG#] as register_nbr,
	t1.[CSTRN#] as transaction_nbr,
	t1.[CSSEQ#] as sequence_number,
	t1.[CSDTYP] as transaction_code,
	t1.CSTIME as transaction_time,
	case t1.[CSSKU#] 
       when 0 then NULL
       else t1.[cssku#]
    end as sku_number,
	t2.d_and_w_item_number as ISBN,
	t1.CSQTY as item_quantity,
	t1.CSRETL as unit_retail,
	t1.CSCOST as unit_cost,
	t1.CSEXPR as extended_price,
	t1.CSEXDS as extended_Discount,
	case t1.CSPOVR
	  when 'P' then 'Y'
	  else 'N'
	end as price_override,
	t1.CSRGPR as unit_regular_price,
	RTRIM(LTRIM(t1.CSRSNC)) as reason_code,
	@rundate as load_date
from Staging.dbo.Detail_Transaction_Rebuild_Raw t1 
left join Reference.dbo.item_dim t2 on
t2.sku_number = cast(t1.[CSSKU#] as bigint)
where CSSTOR <> '54'


end
GO
