USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_coop_Validation]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[usp_Build_coop_Validation]
as
--

declare @pub			varchar(6)
declare @Buyer			varchar(3)
declare	@Purchases_TY	Money
declare @Purchases_LY	Money
declare @Returns_TY		Money
declare @Returns_LY		Money
declare @Sales_TY		Money
declare @Sales_LY		Money
declare @Inv_LY			Money
declare @Inv_TY			Money
declare @CoOp_TY		Money
declare @CoOp_LY		Money
declare @startdate smalldatetime
declare @enddate smalldatetime

--
-- Setup the date variables for the procedure
--
-- Get the fiscal information first.
--
declare @fiscal_year int
declare @fiscal_Period int
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @Fiscal_Period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @fiscal_Period = @Fiscal_Period - 1
if @fiscal_period = 0
	begin
	set @fiscal_period = 12
	set @fiscal_year = @fiscal_Year - 1
	end
else
	set @fiscal_Period = @Fiscal_Period 
	
select @startdate = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = 1
select @enddate = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period



--
-- First, clear out the table and put in empty rows for each pub
--

--
-- Get This Year date variables.
--
declare @TY_Start		smalldatetime
declare @TY_Start_Int	int
declare @TY_End			smalldatetime
declare @TY_End_Int		int
--
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @TY_Start_Int = staging.dbo.fn_DateToInt(@TY_Start)
select @TY_End = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @TY_End_Int = staging.dbo.fn_DateToInt(@TY_End)
--
-- Get Last Year date variables.
--
declare @LY_Start smalldatetime
declare @LY_Start_Int int
declare @LY_End smalldatetime
declare @LY_End_Int int

declare @fiscal_year_ytd int
declare @fiscal_period_start int
--
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year - 1
select @LY_Start_Int = staging.dbo.fn_DateToInt(@LY_Start)
select @LY_End = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year - 1 and fiscal_period = @fiscal_period
select @LY_End_Int = staging.dbo.fn_DateToInt(@LY_End)

select   @fiscal_period = 
fiscal_period from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales) 

select @fiscal_period_start = 
fiscal_period+1 from reference.dbo.calendar_dim
where day_date in( select min(day_date) from dssdata..weekly_sales) 



select   @fiscal_year_ytd = 
fiscal_year from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales) --added by Larry Eady 04/11/2011






truncate table staging..coop_cy
truncate table staging..coop_ly
insert into staging..coop_cy

select * 
from 
(
select claimyear as CY,claimmonth as Month,sum(claimamount) as claim_amount
from BAMITR08.CoOpApp.dbo.Contractclaim
where claimyear =@fiscal_year_ytd-1
and claimmonth between @fiscal_period_start and  @fiscal_period
group by claimmonth,claimyear
) x




insert into  staging..coop_ly
select * 

from 
(
select claimyear as LY,claimmonth as Month,sum(claimamount) as claim_amount
from BAMITR08.CoOpApp.dbo.Contractclaim
where claimyear =@fiscal_year_ytd-2
and claimmonth between @fiscal_period_start and  @fiscal_period
group by claimmonth,claimyear
)y


select *
from staging..coop_cy as a
left join staging..coop_ly as b 
on a.month=b.month
GO
