USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Build_Stock_to_Sales_Rpt_Data_leslie]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE procedure [dbo].[Build_Stock_to_Sales_Rpt_Data_leslie]
as
--- stock to sales report  ---
declare @fiscal_year int
declare @fiscal_period_end int
declare @fiscal_period_end_year int --added 1/23/2012
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
declare @ytd_prev smalldatetime
declare @fiscal_year_week smalldatetime
declare @t smalldatetime
declare @a smalldatetime
declare @u smalldatetime

select   @fiscal_year = 
fiscal_year from reference.dbo.calendar_dim
where day_date in( select max(day_date) from staging..weekly_sales_lesliea)

select  @fiscal_period =fiscal_period from reference.dbo.calendar_dim where day_date in( select max(day_date) from staging..weekly_sales_lesliea)
select @fiscal_period
--select @Fiscal_Period_end = @Fiscal_Period+1 removed 1/23/2012. Case statements below added.
select @fiscal_period_end = CASE 
	When @fiscal_period = 12 THEN 1
	Else @fiscal_period + 1
End

select @fiscal_period_end_year = CASE
	When @fiscal_period = 12 THEN @fiscal_year + 1
	ELSE @fiscal_year
End

select   @period_start =  day_date from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period and day_of_period = 1
--select @period_end = day_date-1 from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period_end and day_of_period = 1 modified 1/23/2012
select @period_end = day_date-1 from reference.dbo.calendar_dim where fiscal_year = @fiscal_period_end_year and fiscal_period = @fiscal_period_end and day_of_period = 1
select @period_end

set @b = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()-365))

set @s = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()+3))
set @a=@s+1

set @prev_wk =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()+3), GETDATE()+3),102)

set @prev_yr =
convert(varchar(10),DATEADD(dd, 1 - DATEPART(dw, GETDATE()-365), GETDATE()-365),102)


 select @ytd =day_date from reference..calendar_dim where @fiscal_year =fiscal_year and day_of_fiscal_year =1

 select @fiscal_year_prev = @fiscal_year-1

 select @ytd_prev  =day_date from reference..calendar_dim where @fiscal_year_prev =fiscal_year and day_of_fiscal_year =1
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


set @t = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()-365))
-- +1


set @u = staging.dbo.fn_Last_Saturday(dateadd(dd,+1,GETDATE()-365)) +1

/*set @period_end = '2012-12-29 00:00:00'
set @period_start = '2012-11-25 00:00:00'
set @period_start_prev = '2012-11-27 00:00:00'
set @s = '2012-12-22 00:00:00'
set @fiscal_year_prev_start = '2012-01-30 00:00:00'
set @ytd = '2012-01-29 00:00:00'
set @t = '2012-12-24 00:00:00'
set @a = '2012-12-23 00:00:00'
set @u = '2011-12-25 00:00:00'
*/
set @t = '2011-12-24 00:00:00'
set @u = '2011-12-25 00:00:00'
select @period_end,@period_start ,@period_start_prev 
,@s
,@fiscal_year_prev_start 
,@ytd 
,@t 
,@a 
,@u 





----- Current Week Measures --------

SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into #current_week
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     (staging.dbo.Weekly_Sales_lesliea.Day_Date = @s) AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName





--- current week summary --- 
select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as current_week_dollars, 
sum(current_units) as current_week_units,fiscal_year_week,fiscal_period_week

into #current_week_summary
from #current_week as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class,fiscal_year_week,fiscal_period_week




--


--
----Current Period to Date Measures --- 

SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into #current_period_to_date
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     staging.dbo.Weekly_Sales_lesliea.Day_Date between  @period_start and @period_end
AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName


--- current period to date summary 


select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as current_ptd_dollars, 
sum(current_units) as current_ptd_units

into #current_period_to_date_summary

from #current_period_to_date as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class








------Current Year to Date Measures --- 

SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into #current_year_to_date
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     staging.dbo.Weekly_Sales_lesliea.Day_Date between @ytd and @s
AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName








--- current year to date summary --- 



select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as current_ytd_dollars, 
sum(current_units) as current_ytd_units

into #current_year_to_date_summary

from #current_year_to_date as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class

----



--- Prior Year Measures ----- 


SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into #current_week_prior_yr
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     (staging.dbo.Weekly_Sales_lesliea.Day_Date = @t)AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName




--- current week  prior year summary --- 
select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as PY_week_dollars, 
sum(current_units) as PY_week_units,fiscal_year_week,fiscal_period_week

into #current_week_prior_year_summary
from #current_week_prior_yr  as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class,fiscal_year_week,fiscal_period_week




--
----Prior Year Period to Date Measures --- 

SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into 
 
#prior_yr_period_to_date
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     staging.dbo.Weekly_Sales_lesliea.Day_Date between  @period_start_prev and @t  
AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName



--- prior year  period to date summary 


select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as current_ptd_dollars, 
sum(current_units) as current_ptd_units

into #prior_yr_period_to_date_summary

from #prior_yr_period_to_date as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class





----Prior Year to Date Measures --- 

SELECT     Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      SUM(Weekly_Sales_lesliea.Current_Dollars) AS Current_Dollars, Weekly_Sales_lesliea.Day_Date, SUM(Weekly_Sales_lesliea.Current_Units) AS Current_Units, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
into

 #prior_year_to_date
FROM         staging.dbo.Weekly_Sales_lesliea INNER JOIN
                      Reference.dbo.Item_Master ON Weekly_Sales_lesliea.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     staging.dbo.Weekly_Sales_lesliea.Day_Date between @fiscal_year_prev_start and @t
AND (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
GROUP BY Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SClass, 
                      Weekly_Sales_lesliea.Day_Date, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, 
                      Reference.dbo.Item_Master.SClass_Name, Reference.dbo.Item_Master.BuyerName
--






--- prior year to date summary --- 



select 
dept,sdept,sclass, dept_name, sdept_name,
class_name,class,buyername,cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50))+'-'+cast(t.sclass as nvarchar(50)) as [key1],
cast(t.dept as nvarchar(50))+'-'+cast(t.sdept as nvarchar(50))+'-'+cast(t.class as nvarchar(50)) as [key2],
sum(current_dollars) as current_ytd_dollars, 
sum(current_units) as current_ytd_units

into 
 
 #prior_year_to_date_summary

from  #prior_year_to_date as t
inner join reference..calendar_dim as c
on t.day_date =c.day_date
group by 
dept,sdept,sclass, dept_name, sdept_name,
class_name,buyername,class





-- Current Week Inventory --- 






select dept,sdept,class,sclass,sum(total_onhand) as Total_onhand,sum(total_onhand *retail) as onhand_retail_CY,
cast(dept as nvarchar(50))+'-'+cast(sdept as nvarchar(50))+'-'+cast(class as nvarchar(50))+'-'+cast(sclass as nvarchar(50)) as [key1],
dept_name,sdept_name,class_name,sclass_name,buyername
into
 #tmp_curr_wk_inventory
from 
(


SELECT     staging.dbo.CARD_History_leslie.sku_number, staging.dbo.CARD_History_leslie.day_date, staging.dbo.CARD_History_leslie.Retail, 
                      staging.dbo.CARD_History_leslie.Total_OnHand, Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, 
                      Reference.dbo.Item_Master.SClass,dept_name,sdept_name,class_name,sclass_name,buyername
FROM         staging.dbo.CARD_History_leslie INNER JOIN
                      Reference.dbo.Item_Master ON staging.dbo.CARD_History_leslie.sku_number = Reference.dbo.Item_Master.SKU_Number
inner join reference..calendar_dim as c on  staging.dbo.CARD_History_leslie.day_date = c.day_date 


where staging.dbo.CARD_History_leslie.day_date =@a
and dept not in( '2','16')
) x 

group by dept,sdept,class,sclass,dept_name,sdept_name,class_name,sclass_name,buyername


--- on order retail --- 


select dept,sdept,class,sclass,sum(qty_onorder *retail) as oo_retail_cy,
cast(dept as nvarchar(50))+'-'+cast(sdept as nvarchar(50))+'-'+cast(class as nvarchar(50))+'-'+cast(sclass as nvarchar(50)) as [key1],
dept_name,sdept_name,class_name,sclass_name,buyer
into 
 
 #tmp_curr_wk_onorder
from 
dssdata..card
where dept not in ('2','16')
group by dept,sdept,class,sclass,dept_name,sdept_name,class_name,sclass_name,buyer







-- Previous Year Inventory --- 



select dept,sdept,class,sclass,sum(total_onhand) as Total_onhand,sum(total_onhand *retail) as onhand_retail_PY,
cast(dept as nvarchar(50))+'-'+cast(sdept as nvarchar(50))+'-'+cast(class as nvarchar(50))+'-'+cast(sclass as nvarchar(50)) as [key1],
dept_name,sdept_name,class_name,sclass_name,buyername
into
  #tmp_prev_yr_inventory
from 
(


SELECT     staging.dbo.CARD_History_leslie.sku_number, staging.dbo.CARD_History_leslie.day_date, staging.dbo.CARD_History_leslie.Retail, 
                      staging.dbo.CARD_History_leslie.Total_OnHand, Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, 
                      Reference.dbo.Item_Master.SClass,dept_name,sdept_name,class_name,sclass_name,buyername
FROM         staging.dbo.CARD_History_leslie INNER JOIN
                      Reference.dbo.Item_Master ON staging.dbo.CARD_History_leslie.sku_number = Reference.dbo.Item_Master.SKU_Number
inner join reference..calendar_dim as c on  staging.dbo.CARD_History_leslie.day_date = c.day_date 


where staging.dbo.CARD_History_leslie.day_date = @u
and dept not in( '2','16')
) x 

group by dept,sdept,class,sclass,dept_name,sdept_name,class_name,sclass_name,buyername






---- weeks of supply -------- 

select dept,sdept,class,sclass,sum(current_units * pos_price) as wos,cast(dept as nvarchar(50))+'-'+cast(sdept as nvarchar(50))+'-'+cast(class as nvarchar(50))+'-'+cast(sclass as nvarchar(50)) as [key1],
dept_name,sdept_name,class_name,sclass_name,buyername
into  #tmp_wos
from 
(
SELECT     Reference.dbo.Item_Master.SKU_Number, Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, Reference.dbo.Item_Master.Class, 
                      Reference.dbo.Item_Master.SClass, Reference.dbo.Item_Master.POS_Price, staging.dbo.Weekly_Sales_lesliea.Current_Units, 
                      staging.dbo.Weekly_Sales_lesliea.Day_Date,dept_name,sdept_name,class_name,sclass_name,buyername
FROM         Reference.dbo.Item_Master INNER JOIN
                      staging.dbo.Weekly_Sales_lesliea ON Reference.dbo.Item_Master.SKU_Number = staging.dbo.Weekly_Sales_lesliea.Sku_Number
WHERE     staging.dbo.Weekly_Sales_lesliea.Day_Date BETWEEN @t AND @s 
--and (staging.dbo.Weekly_Sales_lesliea.Store_Number > 055)
)x
group by Dept, SDept, Class, SClass,dept_name,sdept_name,class_name,sclass_name,buyername


--zero out last week numbers --
update reportdata..rpt_sls_inventory

set current_week_dollars =0,
current_week_units =0,
current_ptd_units =0,
current_ptd_dollars =0,
current_ytd_dollars =0,
current_ytd_units =0, 
py_week_dollars =0, 
py_week_units =0,
prior_ptd_dollars =0,
prior_ptd_units =0,
prior_ytd_dollars =0,
prior_ytd_units =0,
total_onhand_cy =0,
onhand_retail_cy = 0,
total_onhand_py =0,
onhand_retail_py =0,
wos =0,
oo_retail_cy = 0,
oo_retail_py =0


--- append fields missing from template ---- 
--- current week --- 
insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],[key-2],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
a.[key2],
a.fiscal_year_week


from   #current_week_summary as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null




--- current ptd ---- 

insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],[key-2],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
a.[key2],
@fiscal_year_week


from   

#current_period_to_date_summary as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null



--- current ytd ---- 


insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],[key-2],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
a.[key2],
@fiscal_year_week


from   #current_year_to_date_summary  as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null

--- current week  onorder --- 

insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyer,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
@fiscal_year_week


from   #tmp_curr_wk_onorder  as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null



--- prior year current week --- 




insert into 
reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],[key-2],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
a.[key2],
@fiscal_year_week


from   #current_week_prior_year_summary  as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null


---- prior year ptd ----  



insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
@fiscal_year_week


from   #prior_yr_period_to_date_summary  as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null

--- prior ytd --- 



insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],[key-2],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
a.[key2],
@fiscal_year_week


from   #prior_year_to_date_summary  as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null


--- current year inventory --- 

insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
@fiscal_year_week


from #tmp_curr_wk_inventory
 as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null







--
--
--
--
--
--
---- previous year  inventory --- 
--
--
insert into 

reportdata..rpt_sls_inventory
(dept,sub,cls,buyer,d,s,c,sc,[key-1],fiscal_year_week)

select 
a.dept_name,
a.sdept_name,
a.class_name,
a.buyername,
a.dept,
a.sdept,
a.class,
a.sclass,
a.[key1],
@fiscal_year_week


from  #tmp_prev_yr_inventory 
 as a
left outer join 
reportdata..rpt_sls_inventory as b 
on a.[key1]=b.[key-1]
where b.[key-1] is null





-- update dates  ---
update reportdata..rpt_sls_inventory 
set day_date  =@s
--
update reportdata..rpt_sls_inventory
set fiscal_year_week= c.fiscal_year_week
from  reference..calendar_dim as c
where c.day_date =@s



-- update current week numbers --- 
update  reportdata..rpt_sls_inventory
set current_week_dollars = b.current_week_dollars
,current_week_units = b.current_week_units
from  reportdata..rpt_sls_inventory as a 
inner join  #current_week_summary as b 
 on a.[key-1] =b.[key1]











--- update current ptd numbers ---- 
update  reportdata..rpt_sls_inventory
set current_ptd_dollars = b.current_ptd_dollars,
current_ptd_units = b.current_ptd_units 
 from 
 reportdata..rpt_sls_inventory as a
inner join 
#current_period_to_date_summary as b 
on a.[key-1] =b.[key1]

--- update current ytd numbers ----

update  reportdata..rpt_sls_inventory
set current_ytd_dollars =b.current_ytd_dollars,
current_ytd_units = b.current_ytd_units
from 
 reportdata..rpt_sls_inventory as a 
inner join 
#current_year_to_date_summary as b 
on a.[key-1] =b.[key1]  




--- update current week prior year numbers ---- 
update  reportdata..rpt_sls_inventory
set PY_week_dollars =b.py_week_dollars
,py_week_units = b.py_week_units 
from   reportdata..rpt_sls_inventory as a
inner join  #current_week_prior_year_summary as b 
on a.[key-1] =b.[key1]
 

--- update prior year ptd numbers  ---
update  reportdata..rpt_sls_inventory
set prior_ptd_dollars = b.current_ptd_dollars
,prior_ptd_units = b.current_ptd_units
from  
 reportdata..rpt_sls_inventory as a 
inner join  #prior_yr_period_to_date_summary as b 
on a.[key-1] =b.[key1]


--- update prior ytd numbers ---- 
update  reportdata..rpt_sls_inventory
set prior_ytd_dollars = b.current_ytd_dollars,
prior_ytd_units = b.current_ytd_units
from  reportdata..rpt_sls_inventory as a 
inner join #prior_year_to_date_summary as b
on a.[key-1] =b.[key1]


--- update current yr inventory --- 

update
 reportdata..rpt_sls_inventory

set onhand_retail_CY =b.onhand_retail_CY
,total_onhand_CY =b.total_onhand
from  reportdata..rpt_sls_inventory as a
inner join #tmp_curr_wk_inventory as b 
on a.[key-1]=b.[key1]

--- update current onorder  --- 


update 
 reportdata..rpt_sls_inventory
set oo_retail_cy =b.oo_retail_cy
from  reportdata..rpt_sls_inventory as a
inner join 
#tmp_curr_wk_onorder  as b
on a.[key-1]=b.[key1]



--- update prior yr inventory ---

update
 reportdata..rpt_sls_inventory
set onhand_retail_PY =b.onhand_retail_PY
,total_onhand_PY =b.total_onhand
from  reportdata..rpt_sls_inventory as a
inner join #tmp_prev_yr_inventory as b 
on a.[key-1]=b.[key1]


--- update (wos) annualized measure ---


update
reportdata..rpt_sls_inventory
set wos=b.wos
from 
reportdata..rpt_sls_inventory  as a
inner join #tmp_wos as b 
on a.[key-1]=b.[key1]
where b.dept not in ('2')


drop table #current_week
drop table #current_week_summary
drop table #current_period_to_date
drop table #current_period_to_date_summary
drop table #current_year_to_date
drop table #current_year_to_date_summary
drop table #current_week_prior_yr
---drop table #current_week_prior_yr_summary
drop table #tmp_curr_wk_inventory
drop table #tmp_prev_yr_inventory
drop table #tmp_wos
drop table #current_week_prior_year_summary
drop table #prior_yr_period_to_date
drop table #prior_yr_period_to_date_summary
drop table  #prior_year_to_date
drop table  #prior_year_to_date_summary

GO
