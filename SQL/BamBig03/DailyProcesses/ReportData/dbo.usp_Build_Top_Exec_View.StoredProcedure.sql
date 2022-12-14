USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_Exec_View]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_Exec_View]
as
select distinct dept,dept_name,sdept,sdept_name,class,class_name,sclass,sclass_name into #Cats from dssdata.dbo.card
--
Truncate table ReportData.dbo.rpt_Top_Exec_View
Truncate table Staging.dbo.tmp_TopExecView
--
-- Insert Top 10 Key 4
--
insert into Reportdata.dbo.rpt_Top_Exec_View
select top 10
1 as PrintOrder,
'Top 10 Key 4' as Section,
row_Number() over (order by t1.Week1dollars desc) as Rank,
t1.title as TY_Title,
t1.Author as TY_Author,
t2.Class_Name as TY_Class,
t1.Week1Dollars as TY_SLS$,
t1.Week1Units as TY_SLSU,
t1.BAM_OnHand as OnHand,
isnull(t1.Qty_OnOrder,0) as OnOrder,
NULL as LY_Title,
NULL as LY_Author,
NULL as LY_Class,
NULL as LY_SLS$,
NULL as LY_SLSU
from	dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '4'
and		t2.Dept = t1.Dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars
--

insert into staging.dbo.tmp_TopExecView
select top 10
		row_Number() over (order by t1.Week1Dollars desc) as LYRank,
		t1.title as Title,
		t1.Author,
		t2.Class_Name,
		t1.LYWeek1Dollars as Sls$,
		t1.LYWeek1Units as SlsU
from	Dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '4'
and		t2.Dept = t1.Dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by LYWeek1Dollars desc
--
update ReportData.dbo.rpt_Top_Exec_View
set		LY_Title = Title,
		LY_Author = Author,
		LY_Class = Class,
		LY_SLS$ = SLS$,
		LY_SLSU = SLSU
from	Staging.dbo.tmp_TopExecView
where	Staging.dbo.tmp_TopExecView.LYRank = Rank
and		Section = 'Top 10 Key 4'
--
truncate table staging.dbo.tmp_TopExecView
--
-- Insert Top 10 Key 8
--
insert into Reportdata.dbo.rpt_Top_Exec_View
select top 10
1 as PrintOrder,
'Top 10 Key 8' as Section,
row_Number() over (order by t1.Week1Dollars desc) as Rank,
t1.title as TY_Title,
t1.Author as TY_Author,
t2.Class_Name as TY_Class,
t1.Week1Dollars as TY_SLS$,
t1.Week1Units as TY_SLSU,
t1.BAM_OnHand as OnHand,
isnull(t1.Qty_OnOrder,0) as OnOrder,
NULL as LY_Title,
NULL as LY_Author,
NULL as LY_Class,
NULL as LY_SLS$,
NULL as LY_SLSU
from	dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '8'
and		t2.Dept = t1.Dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars
--

insert into staging.dbo.tmp_TopExecView
select top 10
		row_Number() over (order by t1.Week1Dollars desc) as LYRank,
		t1.title as Title,
		t1.Author,
		t2.Class_Name,
		t1.LYWeek1Dollars as Sls$,
		t1.LYWeek1Units as SlsU
from	DssData.dbo.CARD t1,
		#Cats t2
where	t1.dept = '8'
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars desc
--
update ReportData.dbo.rpt_Top_Exec_View
set		LY_Title = Title,
		LY_Author = Author,
		LY_Class = Class,
		LY_SLS$ = SLS$,
		LY_SLSU = SLSU
from	Staging.dbo.tmp_TopExecView
where	Staging.dbo.tmp_TopExecView.LYRank = Rank
and		Section = 'Top 10 Key 8'
--
truncate table staging.dbo.tmp_TopExecView



--
-- Top 10 Key 1 Mass Market
--
insert into Reportdata.dbo.rpt_Top_Exec_View
select top 10
2 as PrintOrder,
'Top 10 Key 1 Mass Market' as Section,
row_Number() over (order by t1.Week1Dollars desc) as Rank,
t1.title as TY_Title,
t1.Author as TY_Author,
t2.Class_Name as TY_Class,
t1.Week1Dollars as TY_SLS$,
t1.Week1Units as TY_SLSU,
t1.BAM_OnHand as OnHand,
isnull(t1.Qty_OnOrder,0) as OnOrder,
NULL as LY_Title,
NULL as LY_Author,
NULL as LY_Class,
NULL as LY_SLS$,
NULL as LY_SLSU
from dssdata.dbo.card t1,
	#Cats t2
where	t1.dept = '1' 
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
--
insert into staging.dbo.tmp_TopExecView
select top 10
		row_Number() over (order by t1.Week1Dollars desc) as LYRank,
		t1.title as Title,
		t1.Author,
		t2.Class_Name,
		t1.LYWeek1Dollars as Sls$,
		t1.LYWeek1Units as SlsU
from	dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '1' 
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars desc
--
update ReportData.dbo.rpt_Top_Exec_View
set		LY_Title = Title,
		LY_Author = Author,
		LY_Class = Class,
		LY_SLS$ = SLS$,
		LY_SLSU = SLSU
from	Staging.dbo.tmp_TopExecView
where	Staging.dbo.tmp_TopExecView.LYRank = Rank
and		Section = 'Top 10 Key 1 Mass Market'
--
truncate table staging.dbo.tmp_TopExecView
-- 
-- Top 10 Key 6 Gift
--
insert into Reportdata.dbo.rpt_Top_Exec_View
select top 10
3 as PrintOrder,
'Top 10 Key 6 Gift' as Section,
row_Number() over (order by t1.Week1Dollars desc) as Rank,
t1.title as TY_Title,
t1.Author as TY_Author,
t2.Class_Name as TY_Class,
t1.Week1Dollars as TY_SLS$,
t1.Week1Units as TY_SLSU,
t1.BAM_OnHand as OnHand,
isnull(t1.Qty_OnOrder,0) as OnOrder,
NULL as LY_Title,
NULL as LY_Author,
NULL as LY_Class,
NULL as LY_SLS$,
NULL as LY_SLSU
from Dssdata.dbo.card t1,
	 #Cats t2
where	t1.dept = '6' 
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars desc
--
insert into staging.dbo.tmp_TopExecView
select top 10
		row_Number() over (order by t1.Week1Dollars desc) as LYRank,
		t1.title as Title,
		t1.Author,
		t2.Class_Name,
		t1.LYWeek1Dollars as Sls$,
		t1.LYWeek1Units as SlsU
from	dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '6' 
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars desc
--
update ReportData.dbo.rpt_Top_Exec_View
set		LY_Title = Title,
		LY_Author = Author,
		LY_Class = Class,
		LY_SLS$ = SLS$,
		LY_SLSU = SLSU
from	Staging.dbo.tmp_TopExecView
where	Staging.dbo.tmp_TopExecView.LYRank = Rank
and		Section = 'Top 10 Key 6 Gift'
--
truncate table staging.dbo.tmp_TopExecView
--
-- Top 10 Key 8 Audio
--
insert into Reportdata.dbo.rpt_Top_Exec_View
select top 10
4 as PrintOrder,
'Top 10 Key 8 Audio' as Section,
row_Number() over (order by t1.Week1Dollars desc) as Rank,
t1.title as TY_Title,
t1.Author as TY_Author,
t2.Class_Name as TY_Class,
t1.Week1Dollars as TY_SLS$,
t1.Week1Units as TY_SLSU,
t1.BAM_OnHand as OnHand,
isnull(t1.Qty_OnOrder,0) as OnOrder,
NULL as LY_Title,
NULL as LY_Author,
NULL as LY_Class,
NULL as LY_SLS$,
NULL as LY_SLSU
from dssdata.dbo.card t1,
	 #Cats t2
where	t1.dept = '8'
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by Week1Dollars desc
--
insert into staging.dbo.tmp_TopExecView
select top 10
		row_Number() over (order by t1.Week1Dollars desc) as LYRank,
		t1.title as Title,
		t1.Author,
		t2.Class_Name,
		t1.LYWeek1Dollars as Sls$,
		t1.LYWeek1Units as SlsU
from	dssdata.dbo.card t1,
		#Cats t2
where	t1.dept = '8'
and		t2.Dept = t1.dept
and		t2.SDept = t1.sdept
and		t2.class = t1.class
and		t2.sclass = t1.sclass
order by LYWeek1Dollars desc
--
update ReportData.dbo.rpt_Top_Exec_View
set		LY_Title = Title,
		LY_Author = Author,
		LY_Class = Class,
		LY_SLS$ = SLS$,
		LY_SLSU = SLSU
from	Staging.dbo.tmp_TopExecView
where	Staging.dbo.tmp_TopExecView.LYRank = Rank
and		Section = 'Top 10 Key 8 Audio'
--
truncate table staging.dbo.tmp_TopExecView
--
















GO
