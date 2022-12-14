USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_BookClub_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_BookClub_Report]
as
declare @mon int
declare @day int
declare @yr int
declare @sd smalldatetime
declare @pps smalldatetime
declare @fw int
declare @dow int
declare @ppweeks int
declare @pps_test smalldatetime
declare @seldate smalldatetime
--
select @mon = datepart(mm,getdate())
select @yr = datepart(yy,getdate())
select @day = datepart(dd,getdate())
if @day < 7
  begin
  set @mon = @mon - 1
  if @mon = 0
    begin
      set @mon = 12
      set @yr = @yr - 1
	end
  end
--
set @sd = ltrim(str(@mon)) + '/01/' + ltrim(str(@yr))
--set @sd = datepart(getdate()-2)
-- 
select @seldate = staging.dbo.fn_dateonly(staging.dbo.fn_last_saturday(getdate()-21))
select @seldate = dateadd(dd,0,@seldate)

select @fw = fiscal_year_week from reference.dbo.calendar_dim where day_date = @seldate
select @dow = day_of_week_number from reference.dbo.calendar_dim where day_date = @seldate
select @pps = dateadd(dd,(7-@dow),@sd)
select @pps = @seldate
select @sd = @seldate

--select @pps_test = dateadd(ww,1,@pps)
--select @sd,@fw,@pps,@seldate,@pps_test
--select max(day_date) from dssdata.dbo.weekly_sales
--select @sd = @seldate
--
truncate table ReportData.dbo.rpt_Book_Club
--
-- Build 
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		1 as Print_Order,
		'CBAMB' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'CBAMB'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and	t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
-- Build FAITB
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		2 as Print_Order,
		'FAITB' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'FAITB'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
-- Build TEENB
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		3 as Print_Order,
		'TEENB' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'TEENB'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
-- Build PBook
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		4 as Print_Order,
		'PBOOK' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'PBOOK'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
--
-- Build LITBO
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		5 as Print_Order,
		'LITBO' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'LITBO'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
--
-- Build AFBOK
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		6 as Print_Order,
		'AFBOK' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'AFBOK'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
--
-- Build ROMBC
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		6 as Print_Order,
		'ROMBC' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'ROMBC'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		6 as Print_Order,
		'NOFBC' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'NOFBC'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		6 as Print_Order,
		'PETBC' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'PETBC'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 
--
--
-- Build KIDBC
--
insert into ReportData.dbo.rpt_Book_Club
select	top 10
		@sd as Start_Date,
		@fw as Start_Week,
		4 as Print_Order,
		'KIDBC' as Section,
		row_Number() over (order by sum(t1.current_dollars) desc) as Rank, 
		t2.sku_number,
		t4.Sr_Buyer,
		t4.Buyer,
		t1.Item_Name as Title, 
		t4.Author as Author, 
		t4.BAM_OnHand,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = @pps and dssdata.dbo.weekly_sales.sku_number = t1.sku_number
		 group by sku_number) as Wk1_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = @pps and sku_number = t1.sku_number) as Wk1_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,1,@pps) and sku_number = t1.sku_number) as Wk2_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww,2,@pps) and sku_number = t1.sku_number) as Wk3_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 3,@pps) and sku_number = t1.sku_number) as Wk4_SLSU,
		(select sum(current_dollars) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSD,
		(select sum(current_Units) from dssdata.dbo.weekly_sales
         where day_date = dateadd(ww, 4,@pps) and sku_number = t1.sku_number) as Wk5_SLSU
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2,
		reference.dbo.category_master t3,
		dssdata.dbo.card t4
where	t2.Coordinate_Group = 'KIDBC'
		and t1.sku_number = t2.sku_number
		and t1.day_date >= @sd
		and t3.dept = t2.dept
		and t3.subdept = t2.sdept
		and t3.class = t2.class	
		and t3.subclass = t2.sclass
		and t4.sku_number = t1.sku_number
group by t1.sku_number,t2.sku_number,t4.sr_buyer,t4.buyer,t1.item_name,t4.author,t4.BAM_OnHand
order by sum(t1.current_Dollars) desc 

select * from ReportData.dbo.rpt_Book_Club
GO
