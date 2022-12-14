USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_Prop_Rpt_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--- time


-- need to verify time constraints before adding time logic
--SET DATEFIRST 2
--
--DECLARE @TodayDayOfWeek INT
--DECLARE @EndOfPrevWeek DateTime
--DECLARE @StartOfPrevWeek DateTime
--
--SET @TodayDayOfWeek = datepart(dw, GetDate())
---
--SET @EndOfPrevWeek = DATEADD(dd, -@TodayDayOfWeek, GetDate())
--select @endofprevweek
--select @TodayDayOfWeek 

--

--- insert into temporary prop table ---




CREATE procedure [dbo].[Build_Prop_Rpt_Data]
as


truncate table reportdata..prop_rpt

SELECT ISBN,
Sku_Number, 
Title, 
Pub_Code, 
Buyer, 
Dept, 
SDept, 
SDept_Name, 
Class, 
Class_Name, 
Sku_Type, 
DWCost, 
Retail, 
IDate, 
BAM_OnHand, 
InTransit, 
Warehouse_OnHand, 
Qty_OnOrder, 
Week1Units, 
Week1Dollars, 
Week2Units, 
Week2Dollars, 
Week3Units, 
Week3Dollars, 
TYYTDDollars, 
TYYTDUnits, 
LYYTDDollars, 
LYYTDUnits,
CAST(CONVERT(varchar, load_date, 112) AS DateTime) as load_date,
coordinate_group 
INTO #PROP1 

FROM dssdata..card as c
where 
c.coordinate_group 
in (
'PROP','PROMO','PROPS','PROPA'
)




--
INSERT INTO #PROP1 
( ISBN, 
Sku_Number, Title, Pub_Code, 
Buyer, Dept, SDept,SDept_Name, 
Class, Class_Name, Sku_Type, 
DWCost, Retail, IDate, 
BAM_OnHand, InTransit, Warehouse_OnHand, 
Qty_OnOrder, Week1Units, Week1Dollars, Week2Units, 
Week2Dollars, Week3Units, Week3Dollars, 
TYYTDDollars, TYYTDUnits, LYYTDDollars, LYYTDUnits,load_date,coordinate_group )

SELECT ISBN, Sku_Number, Title, Pub_Code, 
Buyer, Dept, SDept, SDept_Name, 
Class, Class_Name, Sku_Type, DWCost, 
Retail, IDate, BAM_OnHand, 
InTransit, Warehouse_OnHand, Qty_OnOrder, 
Week1Units, Week1Dollars, Week2Units, Week2Dollars,
Week3Units, Week3Dollars, TYYTDDollars, 
TYYTDUnits, LYYTDDollars, LYYTDUnits,
 CAST(CONVERT(varchar, load_date, 112) AS DateTime) as load_date,
coordinate_group 


FROM dssdata..CARD
WHERE Pub_Code In 
('AFE','BSM','DRR','IAR','IFH','MDD') 
AND (Dept=6) AND (Coordinate_Group) Not In ('PROP','PROMO','PROPS','PROPA')


select p.*,cast(dept as nvarchar(255))+'-'+cast(sdept as nvarchar(255))+ '-'+cast(c.fiscal_year_week as nvarchar(255)) as [key],
c.fiscal_year_week-1  as fiscal_year_week
into #prop2
from #prop1 as p 
inner join reference..calendar_dim as c
on p.load_date =c.day_date 



--- weeks on supply formula ----
select b.*,
(b.week1dollars/[%ttl])/52 as [weekpercent]
into #prop3
from #prop2 as b
left join tmp_load..percentage as p
on b.[key] = p.[key]




INSERT INTO reportdata..prop_rpt
( ISBN, 
Sku_Number, Title, Pub_Code, 
Buyer, Dept, SDept,SDept_Name, 
Class, Class_Name, Sku_Type, 
DWCost, Retail, IDate, 
BAM_OnHand, InTransit, Warehouse_OnHand, 
Qty_OnOrder, Week1Units, Week1Dollars, Week2Units, 
Week2Dollars, Week3Units, Week3Dollars, 
TYYTDDollars, TYYTDUnits, LYYTDDollars, LYYTDUnits,load_date,
[key],fiscal_year_week,weekpercent,coordinate_group)

select 
ISBN, 
Sku_Number, Title, Pub_Code, 
Buyer, Dept, SDept,SDept_Name, 
Class, Class_Name, Sku_Type, 
DWCost, Retail, IDate, 
BAM_OnHand, InTransit, Warehouse_OnHand, 
Qty_OnOrder, Week1Units, Week1Dollars, Week2Units, 
Week2Dollars, Week3Units, Week3Dollars, 
TYYTDDollars, TYYTDUnits, LYYTDDollars, LYYTDUnits,load_date,
[key],fiscal_year_week,weekpercent,coordinate_group
from 
#prop3
drop table #prop1
drop table #prop2
drop table #prop3






GO
