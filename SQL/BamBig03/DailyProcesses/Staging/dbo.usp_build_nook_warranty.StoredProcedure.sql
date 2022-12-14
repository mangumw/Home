USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_nook_warranty]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_nook_warranty] as 



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
declare @a smalldatetime
declare @c smalldatetime
declare @b smalldatetime
declare @fiscal_year_prev_start smalldatetime
declare @fiscal_year_prev int
declare @ytd smalldatetime
declare @fiscal_year_week smalldatetime
--

select   @fiscal_year = 
fiscal_year from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales)

select  @fiscal_period =fiscal_period from reference.dbo.calendar_dim where day_date in( select max(day_date) from dssdata..weekly_sales)

select @Fiscal_Period_end = @Fiscal_Period+1 
select   @period_start =  day_date from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period and day_of_period = 1
select @period_end = day_date-1 from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period_end and day_of_period = 1


set @b = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()-365))

set @s = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()))

set @a =@s-6
set @c=@b-6
set @prev_wk =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()), GETDATE()),102)

set @prev_yr =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()-365), GETDATE()-365),102)



truncate table reportdata..nook_warranty
insert into reportdata..nook_warranty
select a.store_number,
b.isbn,
b.sku_number as sku,
b.title,
b.dept,
b.retail,
a.item_quantity,
sum(a.extended_price) as [ext price],
sum(a.unit_cost) as cost

from dssdata..detail_transaction_history  as a inner join 
dssdata..card as b on a.sku_number =b.sku_number
where a.day_date between @a and @s and 
b.dept ='76'

group by 
a.store_number,
b.isbn,
b.sku_number,
b.title,
b.dept,
a.item_quantity,
b.retail

GO
