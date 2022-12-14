USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_sku_sales_by_Dept]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
     [dbo].[usp_build_sku_sales_by_Dept]
AS 

declare @fiscal_Year int

--

declare @Wk1dt smalldatetime

declare @Wk2dt smalldatetime

declare @Wk3dt smalldatetime

declare @Wk4dt smalldatetime

declare @Wk5dt smalldatetime

declare @Wk6dt smalldatetime

declare @Wk7dt smalldatetime

declare @Wk8dt smalldatetime

declare @Wk9dt smalldatetime

declare @Wk10dt smalldatetime

declare @Wk11dt smalldatetime

declare @Wk12dt smalldatetime

declare @Wk13dt smalldatetime

declare @fiscal_year_week smalldatetime


--

declare @Wk1lydt smalldatetime

declare @Wk2lydt smalldatetime

declare @Wk3lydt smalldatetime

declare @Wk4lydt smalldatetime

declare @Wk5lydt smalldatetime

declare @Wk6lydt smalldatetime

declare @Wk7lydt smalldatetime

declare @Wk8lydt smalldatetime

declare @Wk9lydt smalldatetime

declare @Wk10lydt smalldatetime

declare @Wk11lydt smalldatetime

declare @Wk12lydt smalldatetime

declare @Wk13lydt smalldatetime

declare @today smalldatetime

declare @lyToday smalldatetime

declare @lyEnd smalldatetime

--

select @today = staging.dbo.fn_Last_Saturday(getdate())

select @lyToday = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))

select @fiscal_Year = fiscal_year from reference.dbo.calendar_dim where day_date = @LYToday

select @LYEnd = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_Year

select @Wk1dt = @today

select @Wk2dt = dateadd(ww,-1,@today)

select @Wk3dt = dateadd(ww,-2,@today)

select @Wk4dt = dateadd(ww,-3,@today)

select @Wk5dt = dateadd(ww,-4,@today)

select @Wk6dt = dateadd(ww,-5,@today)

select @Wk7dt = dateadd(ww,-6,@today)

select @Wk8dt = dateadd(ww,-7,@today)

select @Wk9dt = dateadd(ww,-8,@today)

select @Wk10dt = dateadd(ww,-9,@today)

select @Wk11dt = dateadd(ww,-10,@today)

select @Wk12dt = dateadd(ww,-11,@today)

select @Wk13dt = dateadd(ww,-12,@today)

--

select @Wk1lydt = @lyToday

select @Wk2lydt = dateadd(ww,-1,@lyToday)

select @Wk3lydt = dateadd(ww,-2,@lyToday)

select @Wk4lydt = dateadd(ww,-3,@lyToday)

select @Wk5lydt = dateadd(ww,-4,@lyToday)

select @Wk6lydt = dateadd(ww,-5,@lyToday)

select @Wk7lydt = dateadd(ww,-6,@lyToday)

select @Wk8lydt = dateadd(ww,-7,@lyToday)

select @Wk9lydt = dateadd(ww,-8,@lyToday)

select @Wk10lydt = dateadd(ww,-9,@lyToday)

select @Wk11lydt = dateadd(ww,-10,@lyToday)

select @Wk12lydt = dateadd(ww,-11,@lyToday)

select @Wk13lydt = dateadd(ww,-12,@lyToday)

select @fiscal_year_week =fiscal_year_week 
from reference..calendar_dim
where day_date =@Wk1dt 

--

--drop table #TYitems

select  t2.day_date,

            t1.sku_number,

            sum(t2.current_units) as SLSU

into  #TYItems

from  dssdata.dbo.card t1,

            dssdata.dbo.weekly_sales t2

where t1.Dept in (6, 3, 12, 13, 14, 16, 58, 69)

and         t1.Sku_Type in ('T', 'N', 'R', 'B')

and         t1.Status = 'A'

and         t1.Store_Min > 0

and         t2.sku_number = t1.sku_number

and         t2.day_date >= @wk13dt

group by t2.day_date,t1.sku_number

--

--drop table #LYitems

select  t2.day_date,

            t1.sku_number,

            sum(t2.current_units) as SLSU

into  #LYItems

from  dssdata.dbo.card t1,

            dssdata.dbo.weekly_sales t2

where t1.Dept in (6, 3, 12, 13, 14, 16, 58, 69)

and         t1.Sku_Type in ('T', 'N', 'R', 'B')

and         t1.Status = 'A'

and         t1.Store_Min > 0

and         t2.sku_number = t1.sku_number

and         t2.day_date >= @wk13lydt and t2.day_date <= @LYEnd

group by t2.day_date,t1.sku_number

--

select      sku_number,

            sum(case when day_date = @wk1dt then SLSU else 0 END) as Week1,

            sum(case when day_date = @wk2dt then SLSU else 0 END) as Week2,

            sum(case when day_date = @wk3dt then SLSU else 0 END) as Week3,

            sum(case when day_date = @wk4dt then SLSU else 0 END) as Week4,

            sum(case when day_date = @wk5dt then SLSU else 0 END) as Week5,

            sum(case when day_date = @wk6dt then SLSU else 0 END) as Week6,

            sum(case when day_date = @wk7dt then SLSU else 0 END) as Week7,

            sum(case when day_date = @wk8dt then SLSU else 0 END) as Week8,

            sum(case when day_date = @wk9dt then SLSU else 0 END) as Week9,

            sum(case when day_date = @wk10dt then SLSU else 0 END) as Week10,

            sum(case when day_date = @wk11dt then SLSU else 0 END) as Week11,

            sum(case when day_date = @wk12dt then SLSU else 0 END) as Week12,

            sum(case when day_date = @wk13dt then SLSU else 0 END) as Week13

into  #TY

from  #TYItems

group by sku_number

order by sku_number

--

select      sku_number,

            sum(case when day_date = @wk1lydt then SLSU else 0 END) as LYWeek1,

            sum(case when day_date = @wk2lydt then SLSU else 0 END) as LYWeek2,

            sum(case when day_date = @wk3lydt then SLSU else 0 END) as LYWeek3,

            sum(case when day_date = @wk4lydt then SLSU else 0 END) as LYWeek4,

            sum(case when day_date = @wk5lydt then SLSU else 0 END) as LYWeek5,

            sum(case when day_date = @wk6lydt then SLSU else 0 END) as LYWeek6,

            sum(case when day_date = @wk7lydt then SLSU else 0 END) as LYWeek7,

            sum(case when day_date = @wk8lydt then SLSU else 0 END) as LYWeek8,

            sum(case when day_date = @wk9lydt then SLSU else 0 END) as LYWeek9,

            sum(case when day_date = @wk10lydt then SLSU else 0 END) as LYWeek10,

            sum(case when day_date = @wk11lydt then SLSU else 0 END) as LYWeek11,

            sum(case when day_date = @wk12lydt then SLSU else 0 END) as LYWeek12,

            sum(case when day_date = @wk13lydt then SLSU else 0 END) as LYWeek13

into  #LY

from  #LYItems

group by sku_number

order by sku_number

--
TRUNCATE TABLE ReportData.dbo.sku_sales_by_Dept

INSERT into ReportData.dbo.sku_sales_by_Dept

select      t3.Dept,

            t1.sku_number,

            t3.ISBN,

            t3.Title,

            t3.Author,

            t3.Pub_Code,

            t3.Sku_Type,

            t3.Retail,

            t3.BAM_OnHand, 

        t3.InTransit, 

            t3.BAM_OnOrder, 

            t3.Warehouse_OnHand, 

            t3.ReturnCenter_OnHand, 

        t3.Qty_OnOrder, 

            t3.Qty_OnBackorder, 

            t3.Status, 

            t3.IDate, 

        t3.Store_Min, 

            t4.Standard_Pack,

            t1.Week1,

            t1.Week2,         

            t1.Week3,

            t1.Week4,

            t1.Week5,

            t1.Week6,

            t1.Week7,

            t1.Week8,

            t1.Week9,

            t1.Week10,

            t1.Week11,

            t1.Week12,

            t1.Week13,

            t2.LYWeek1,

            t2.LYWeek2,

            t2.LYWeek3,

            t2.LYWeek4,

            t2.LYWeek5,

            t2.LYWeek6,

            t2.LYWeek7,

            t2.LYWeek8,

            t2.LYWeek9,

            t2.LYWeek10,

            t2.LYWeek11,

            t2.LYWeek12,

            t2.LYWeek13,
             @wk1dt,
            @fiscal_year_week


from  #TY t1 left join #LY t2

on          t2.sku_number = t1.sku_number

left join dssdata.dbo.card t3 on t3.sku_number = t1.sku_number

left join reference.dbo.invmst t4

on          t4.sku_number = t1.sku_number

GO
