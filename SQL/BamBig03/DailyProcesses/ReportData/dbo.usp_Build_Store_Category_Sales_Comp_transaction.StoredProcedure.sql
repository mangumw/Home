USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Category_Sales_Comp_transaction]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Store_Category_Sales_Comp_transaction]

as

--- extension of store category sales report - bringing transaction ct -- addded by Larry Eady 04/07/2011
declare @fiscal_year int
declare @fiscal_period_end int
declare @period_end smalldatetime
declare @period_start smalldatetime
declare @period_start_prev smalldatetime
declare @period_end_prev smalldatetime
declare @fiscal_period int
declare @prev_wk datetime
declare @prev_yr datetime
declare @s smalldatetime
declare @b smalldatetime
declare @fiscal_year_prev_start smalldatetime
declare @fiscal_year_prev int
declare @ytd smalldatetime
declare @fiscal_year_week smalldatetime
declare @fiscal_quarter varchar(7)
declare @fiscal_quarter_start smalldatetime
declare @fiscal_quarter_end smalldatetime
declare @fiscal_quarter_ly varchar(7)
declare @fiscal_quarter_start_ly smalldatetime
declare @fiscal_quarter_end_ly smalldatetime




select   @fiscal_year = 
fiscal_year from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales)

select  @fiscal_period =fiscal_period from reference.dbo.calendar_dim where day_date in( select max(day_date) from dssdata..weekly_sales)

select @Fiscal_Period_end = @Fiscal_Period+1 
select   @period_start =  day_date from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period and day_of_period = 1
select @period_end = day_date-1 from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period_end and day_of_period = 1


set @b = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()-365))

set @s = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()))

set @prev_wk =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()), GETDATE()),102)

set @prev_yr =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()-365), GETDATE()-365),102)


 select @ytd =day_date from reference..calendar_dim where @fiscal_year =fiscal_year and day_of_fiscal_year =1

 select @fiscal_year_prev = @fiscal_year-1

select @fiscal_year_prev_start =day_date 
from reference..calendar_dim
where @fiscal_year_prev=fiscal_year
and day_of_fiscal_year =1


select @period_start_prev =
 day_date from reference.dbo.calendar_dim where fiscal_year = @fiscal_year_prev
and fiscal_period = @fiscal_period and day_of_period = 1



select @period_end_prev = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year_prev
and fiscal_period = @fiscal_period and fiscal_period_week = 4



select @fiscal_year_week = fiscal_year_week 
from reference..calendar_dim
where day_date =@b


declare @TYday smalldatetime
select @TYday = Dateadd(dd,-1,staging.dbo.fn_DateOnly(Getdate()))

declare @LYday smalldatetime
select @LYday = Dateadd(dd,-365,staging.dbo.fn_DateOnly(Getdate()))+1


select @fiscal_quarter = fiscal_quarter
from reference..calendar_dim 
where day_date =  @tyday



select @fiscal_quarter_start = min(day_date)-2
from reference..calendar_dim 
where fiscal_quarter =@fiscal_quarter


select @fiscal_quarter_end =  max(day_date) 
from reference..calendar_dim 
where fiscal_quarter =@fiscal_quarter
 

select @fiscal_quarter_ly = fiscal_quarter
from reference..calendar_dim 
where day_date =  @lyday

select @fiscal_quarter_start_ly = min(day_date)-1
from reference..calendar_dim 
where fiscal_quarter =@fiscal_quarter_ly






drop table reportdata.dbo.rpt_store_category_sales_Comp_transaction


-- bring current year's qtd transaction count


select count(distinct(ct_key)) as transaction_ct,store_number
into #tmp_transaction_ct_ty
from 
(
select store_number, cast(store_number as varchar(4))+cast(day_date as varchar(12))+cast(register_nbr as varchar(10))+cast(transaction_nbr as varchar(15)) as ct_key
from dssdata..detail_transaction_history
where day_date between @fiscal_quarter_start and  @tyday

)x
group by store_number







--- bring last year's  qtd transaction count --- 

select count(distinct(ct_key)) as transaction_ct,store_number
into #tmp_transaction_ct_ly
from 
(
select store_number, cast(store_number as varchar(4))+cast(day_date as varchar(12))+cast(register_nbr as varchar(10))+cast(transaction_nbr as varchar(15)) as ct_key
from dssdata..detail_transaction_history
where day_date between @fiscal_quarter_start_ly and  @lyday 

)x

group by store_number


--combine both years table --- 

select  a.store_number, 
a.transaction_ct as TY_Transaction_ct,
isnull(b.transaction_ct,0) as LY_Transaction_ct
into #tmp_store_tranaction_ct
from #tmp_transaction_ct_ty as a
left join #tmp_transaction_ct_ly as b 
on a.store_number =b.store_number



-- limit stores to parent report ---
select distinct store_number
into #store
from
reportdata.dbo.rpt_store_category_sales_Comp
order by store_number

---export results into reportdata.dbo.rpt_store_category_sales_Comp_transaction table
select 
a.store_number,
b.ty_transaction_ct,
isnull(b.ly_transaction_ct,0) as ly_transaction_ct
into 
reportdata.dbo.rpt_store_category_sales_Comp_transaction
from #store as a
left join #tmp_store_tranaction_ct as b
on a.store_number =b.store_number


drop table #tmp_transaction_ct_ty
drop table #tmp_transaction_ct_ly
drop table #store
drop table #tmp_store_tranaction_ct
GO
