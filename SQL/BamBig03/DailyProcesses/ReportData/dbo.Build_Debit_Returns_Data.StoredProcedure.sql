USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_Debit_Returns_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[Build_Debit_Returns_Data]
as



declare @fiscal_period int
declare @fiscal_year int 
declare @period_end smalldatetime
declare @period_start smalldatetime
declare @begin_date varchar(8)
declare @end_date varchar (8)
select   @fiscal_year = 
fiscal_year-1 from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales)
select  @fiscal_period =fiscal_period from reference.dbo.calendar_dim where day_date in( select max(day_date) from dssdata..weekly_sales)

select   @period_start =  day_date from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period and day_of_period = 1
select @period_end = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
and fiscal_period = @fiscal_period and fiscal_period_week = 4












select @begin_date =
 cast(fiscal_year as varchar(4))+case when day_of_month_number <10 then '0'+cast(day_of_month_number as varchar(2)) else cast(day_of_month_number as varchar(2)) end  +case when datepart(mm,day_date)<10 then '0'+ cast(datepart(mm,day_date) as varchar(1)) else cast(datepart(mm,day_date) as varchar(2)) end 
from 
reference..calendar_dim
where day_date =@period_start



select @end_date = cast(fiscal_year as varchar(4))+case when day_of_month_number <10 then '0'+cast(day_of_month_number as varchar(2)) else cast(day_of_month_number as varchar(2)) end  +case when datepart(mm,day_date)<10 then '0'+ cast(datepart(mm,day_date) as varchar(1)) else cast(datepart(mm,day_date) as varchar(2)) end 
from 
reference..calendar_dim
where day_date =@period_end


drop table reference..tmp_debit_nbr
select distinct debit_nbr,
customer,
scan_date
into 
reference..tmp_debit_nbr
from 
reference..rtdbdt
where scan_date between @begin_date and @end_date


truncate table  debit_returns_rpt
insert into  debit_returns_rpt

select a.customer as store, 
a.debit_nbr,
count(c.tote_nbr) as totes_count,
c.create_dt,
a.scan_date,
b.Status
,sum(isnull(b.store_qty,0)) as total_units_scanned_out,
sum(isnull(b.return_qty,0)) as total_units_scanned_id
from reference..tmp_debit_nbr as a
left join reference..rtvtrn as b 
on a.debit_nbr =b.debit_number 
left join reference..rtdbte as c
on a.debit_nbr =c.debit_nbr
inner join reference..active_stores as d
on a.customer =d.store_number
where status <>'c'
group  by a.debit_nbr,
customer,
scan_date,
create_dt,
status
order by customer
GO
