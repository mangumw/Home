USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_Debit_Returns_Data_FUSE]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Build_Debit_Returns_Data_FUSE]
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


truncate table  debit_returns_rpt_Fuse
Insert into  debit_returns_rpt_Fuse
SELECT     Reference.dbo.tmp_debit_nbr.customer, Reference.dbo.tmp_debit_nbr.debit_nbr, COUNT(Reference.dbo.RTDBTE.TOTE_NBR) AS totes_count, 
                      Reference.dbo.RTDBTE.CREATE_DT, Reference.dbo.tmp_debit_nbr.scan_date, Reference.dbo.TRFDTL.To_Warehouse, SUM(Reference.dbo.TRFDTL.Qty_Shipped) 
                      AS total_units_scanned_out, SUM(Reference.dbo.rtdbdt.QUANTITY_SCANNED) AS total_units_scanned_id, Reference.dbo.rtdbdt.STATUS
FROM         Reference.dbo.tmp_debit_nbr INNER JOIN
                      Reference.dbo.rtdbdt ON Reference.dbo.tmp_debit_nbr.debit_nbr = Reference.dbo.rtdbdt.DEBIT_NBR INNER JOIN
                      Reference.dbo.RTDBTE ON Reference.dbo.tmp_debit_nbr.debit_nbr = Reference.dbo.RTDBTE.DEBIT_NBR INNER JOIN
                      Reference.dbo.TRNRTN INNER JOIN
                      Reference.dbo.TRFDTL ON Reference.dbo.TRNRTN.TNDBNO = Reference.dbo.TRFDTL.Transfer_Batch ON 
                      Reference.dbo.tmp_debit_nbr.debit_nbr = Reference.dbo.TRNRTN.TNDBNO
GROUP BY Reference.dbo.tmp_debit_nbr.customer, Reference.dbo.tmp_debit_nbr.debit_nbr, Reference.dbo.RTDBTE.CREATE_DT, Reference.dbo.tmp_debit_nbr.scan_date, 
                      Reference.dbo.TRFDTL.To_Warehouse, Reference.dbo.rtdbdt.STATUS
HAVING      (Reference.dbo.RTDBTE.CREATE_DT = 20150101) AND (Reference.dbo.rtdbdt.STATUS <> 'C')
GO
