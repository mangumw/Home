USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_AA_Feature_Store_Ranking]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_AA_Feature_Store_Ranking]
as 
declare @fiscal_quarter varchar(7)
declare @qs smalldatetime
declare @promo varchar(255)
--
select @promo = Promotion from reference.dbo.AA_Feature_Rankings
                where active = 1
--
select @fiscal_quarter = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(getdate())
select @qs = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_quarter


--
-- Create the putput table and populate with all stores for each feature
--
select	distinct t2.Feature,
		NULL as Owner,
		t1.store_number,
		t1.store_name,
		t1.region_number,
		t1.district_number,
		0 as FTD_SLSU,
		0 as FTD_SLSD,
		0 as FTD_Rank,
		0 as WK1_SLSU,
		0 as WK1_SLSD,
		0 as QTD_Rank,
		0 as TotSls_Rank,
		0 as LW_Rank
into	#tmpAA
from	reference.dbo.AA_active_stores t1,
		reference.dbo.AA_Feature_Rankings t2
where	t2.Promotion = @promo
and		t2.show_on_report = 1
and		t2.Active = 1
and     (NOT (t1.Store_number IN (3515, 3577, 3108, 3197, 3253, 3517, 3176, 3487, 2575, 3575, 3387, 3777, 3622, 3313, 3240, 3134, 3286, 3658,  10, 11,2125,9001,9002,
				9003,9004,9005,9006,9007,9008,9010,9011,9012,9013,9014,9015,9016,9017,9018,9019,9020,9015,12, 13, 15, 9999, 99999, 60, 986, 987, 988, 989, 990, 995, 997, 998, 50, 52, 54, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 
                2103,2104,2105,2106,2107,2108,2109,2110,2111,2112,2113,2114,2115,2116,2117,2118,2119,2120,2121,2122,2123,2124,2126,2127,2128,014, 4015, 4017)))
order by t2.feature,t1.Region_Number,t1.District_Number,t1.store_number

--
-- Get Feature To Date Numbers
--
select	t1.Feature,
		Rank () over (partition by t1.feature order by sum(t2.current_dollars) desc) as FTD_Rank,
		NULL as Owner,
		t2.store_number,
		sum(t2.current_units) as FTD_SLSU,
		sum(t2.current_dollars) as FTD_SLSD
into	#tmp1
from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t2.sku_number = t1.sku_number
and		t1.show_on_report = 1
and		t2.day_date >= t1.set_Date and t2.day_date <= t1.unset_Date
where t1.active = 1
group by t1.feature,t2.store_number
order by t1.feature,sum(t2.current_dollars) desc
--
-- Update the output table
--
update	#tmpAA
set		FTD_Rank = #tmp1.FTD_Rank,
		FTD_SLSU = #tmp1.FTD_SLSU,
		FTD_SLSD = #tmp1.FTD_SLSD
from	#tmp1
where	#tmp1.Feature = #tmpAA.Feature
and		#tmp1.store_number = #tmpAA.store_number
--
select	t1.feature,
		t2.store_number,
		sum(t2.current_units) as Week1_SLSU,
		sum(t2.current_dollars) as Week1_SLSD
into	#tmp2
from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t1.show_on_report = 1
and		t1.active = 1
and		t2.sku_number = t1.sku_number
and		t2.day_date = staging.dbo.fn_Last_Saturday(getdate())
group by t1.feature,t2.store_number
order by t1.feature,sum(t2.current_dollars) desc
--
update	#tmpAA
set		Wk1_SLSU = #tmp2.Week1_SLSU,
		Wk1_SLSD = #tmp2.Week1_SLSD
from	#tmp2
where	#tmp2.Feature = #tmpAA.Feature
and		#tmp2.store_number = #tmpAA.store_number
--
-- Get QTD Rank by Feature
--
select	t1.Feature,
		t2.store_number,
		rank () over (partition by t1.Feature order by sum(current_dollars) desc) as QTD_Rank
into	#tmp3
from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t1.show_on_report = 1
and		t1.active = 1
and		t2.sku_number = t1.sku_number
where	t2.day_date >= @qs
group by t1.Feature,t2.Store_Number
order by sum(t2.current_dollars) desc
--
update	#tmpAA
set		QTD_Rank = #tmp3.QTD_Rank
from	#tmp3
where	#tmp3.store_number = #tmpAA.store_number
and		#tmp3.Feature = #tmpAA.Feature
--
select	t2.store_number,
		rank () over (order by sum(current_dollars) desc) as TotSls_Rank,
		sum(t2.current_dollars) as SLSD
into	#tmp4
from	dssdata.dbo.weekly_sales t2
where	t2.day_date >= staging.dbo.fn_Last_Saturday(getdate())
group by store_number
order by sum(current_dollars) desc
--
update	#tmpAA
set		TotSls_Rank = #tmp4.TotSls_Rank
from	#tmp4
where	#tmp4.store_number = #tmpAA.store_number

update #tmpAA
set LW_Rank = reportdata.dbo.aa_feature_store_ranking_lw.rank
from reportdata.dbo.aa_feature_store_ranking_lw
where reportdata.dbo.aa_feature_store_ranking_lw.Store_Number = #tmpAA.Store_Number
and reportdata.dbo.aa_feature_store_ranking_lw.Feature = #tmpAA.Feature
--
truncate table ReportData.dbo.AA_Feature_Store_Ranking
--
insert into ReportData.dbo.AA_Feature_Store_Ranking
select * from #tmpAA
GO
