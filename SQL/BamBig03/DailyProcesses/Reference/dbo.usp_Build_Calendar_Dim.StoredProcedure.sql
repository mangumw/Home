USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Calendar_Dim]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Calendar_Dim]
as

DECLARE @newyear INT = 0
DECLARE @action INT = 0
DECLARE @maxweeks INT 

--Check to see if there is a new year in INVCAL that needs to be added to reference.dbo.calendar_dim
select @newyear += x.miss_year
from
(
select distinct(DATCYR) as miss_year from BKL400.BKL400.MM4R4LIB.INVCAL where 2000+DATCYR not in (select fiscal_year from reference.dbo.calendar_dim) and DATCYR > 10 and DATCYR < 77 
)  as x

--If a year is found, build out the basic info for that year from INVCAL.  (If year is not found, @newyear will be 0)
IF @newyear > 0 
BEGIN

	Select @action = 1

	select @maxweeks = max(DATWKY) from BKL400.BKL400.MM4R4LIB.INVCAL where DATCYR = @newyear 
	
	SELECT convert(DATETIME, CONVERT(CHAR(8), 20000000 + DATBAK)) as Day_date,
	REPLACE(REPLACE(REPLACE(rtrim(DATLIT), 'the ', ''), ' ', '.'), ',', '.') as date_description, -- This is replacing the commas and spaces in the full date name so that it can be parsed later
	case 
		when DATPER in (1,2,3) then Concat(2000 + DATCYR, '-', 'Q1')
		when DATPER in (4,5,6) then Concat(2000 + DATCYR, '-', 'Q2') 
		when DATPER in (7,8,9) then Concat(2000 + DATCYR, '-', 'Q3') 
		when DATPER in (10,11,12) then Concat(2000 + DATCYR, '-', 'Q4') 
	end as fiscal_quarter,
	DATDAY as day_of_week_number,
	DATCDY as day_of_fiscal_year,
	2000 + DATCYR as fiscal_year,
	DATPER as fiscal_period,
	DATWKP as fiscal_period_week,
	DATWKY as fiscal_year_week
    into #tempmain
	from BKL400.BKL400.MM4R4LIB.INVCAL where DATCYR = @newyear


	-- Modify data and insert into reference.dbo.calendar_dim.  This piece joins in two static tables (FiscalWeekDays and CalendarDayMatch to 
	-- set the day of fiscal period and day of calendar year 
	insert into reference.dbo.calendar_dim
	select t1.Day_date, 
	parsename(date_description,4) as day_name,
	parsename(date_description,3) as month_name, 
	day_of_week_number,
	replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','') as day_of_month_number,
	DayofCalendarYear as day_of_year_number,
	parsename(date_description,1) as calendar_year,
	DayofFiscalPeriod as day_of_period,
	day_of_fiscal_year,
	fiscal_year,
	fiscal_quarter,
	fiscal_period,
	fiscal_period_week,
	fiscal_year_week,
	NULL as Calendar_week,
	-- Set weekend flag if day is Saturday or Sunday
	case
	  when parsename(date_description,4) in ('Saturday', 'Sunday') 
	  then 'Y'
	  else 'N'
	end as weekend_flag,
	-- Set first day of month flag if date number is 1
	case	
	  when replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','')  = 1
	  then 'Y'
	  else 'N'
	end as first_day_of_month_flag,
	--Set last day of month flag based on the number of number of days in month, accounting for leap year
	case 
	  when parsename(date_description,3)  in ('January', 'March', 'May', 'July', 'August', 'October', 'December') and 
	  replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','') = 31
	  then 'Y'
	  when parsename(date_description,3)  in ('April', 'June', 'September', 'November') and 
	  replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','') = 30
	  then 'Y'
	  --leap years
	  when parsename(date_description,3) = 'February' and parsename(date_description,1) in (2020,2024,2028,2032,2036,2040,2044,2048,2052)
	  and replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','') = 29
	  then 'Y'
	  when parsename(date_description,3) = 'February' and replace(replace(replace(replace(parsename(date_description,2), 'th',''), 'nd', ''), 'st', ''), 'rd','') = 28
	  then 'Y'
	  else 'N'
	end as last_day_of_month_flag,
	NULL as end_of_pay_period_flag,
	NULL as holiday_flag,
	NULL as holiday_name,
	NULL as major_event_flag,
	NULL as major_event_number,
	getdate() as record_date	
   	from #tempmain t1 left join staging.dbo.FiscalWeekDays t2 on t2.YearWeeks = @maxweeks and t2.DayofFiscalYear = t1.day_of_fiscal_year
	left join staging.dbo.CalendarDayMatch t3 on t1.Day_date = t3.Day_date
	
	--send email notification
	exec  staging.dbo.usp_send_message'big@booksamillion.com','Fiscal Calendar Build Complete',
	'The fiscal calendar has been built for the most recent year in reference.dbo.calendar_dim. 
	Please review the calendar records and update the holiday flag, holiday name, and end of pay period flags.'  

END






	

	










GO
