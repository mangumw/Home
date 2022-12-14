USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[AA_Feature_Store_Ranking_New_OH]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AA_Feature_Store_Ranking_New_OH]
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
TRUNCATE TABLE Reference.dbo.tmpAA
INSERT INTO Reference.dbo.tmpAA
select	distinct t2.Feature,
		NULL as Owner,
		t1.store_number,
		t1.store_name,
		t2.sku_number,
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
from	reference.dbo.active_stores t1,
		reference.dbo.AA_Feature_Rankings t2
where	t2.Promotion = @promo
and		t2.show_on_report = 1
and		t2.Active = 1
and     (NOT (t1.Store_number IN (3515,3577,3108,3197,3253,3517,3176,3487,2575,3575,3387,3777,
3622,3313,3240,3134,3286,3658,2100,2101,2102,10,11,12,13,15,9999,99999,60,986,987,988,989,990,995,997,
998,50,52,54,4001,4002,4003,4004,4005,4006,4007,4008,4009,4010,4011,4012,4013,4014,4015,4017)))
order by t2.feature,t1.Region_Number,t1.District_Number,t1.store_number, t2.sku_number

--
-- Get Feature To Date Numbers
--
TRUNCATE TABLE Reference.dbo.tmp1
INSERT INTO Reference.dbo.tmp1
select	t1.Feature,
		Rank () over (partition by t1.feature order by sum(t2.current_dollars) desc) as FTD_Rank,
		NULL as Owner,
		t2.store_number,
		t2.sku_number,
		sum(t2.current_units) as FTD_SLSU,
		sum(t2.current_dollars) as FTD_SLSD
from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t2.sku_number = t1.sku_number
and		t1.show_on_report = 1
and		t2.day_date >= t1.set_Date and t2.day_date <= t1.unset_Date
where t1.active = 1
group by t1.feature,t2.store_number,t2.sku_number
order by t1.feature,sum(t2.current_dollars) desc
--
-- Update the output table
--
update	Reference.dbo.tmpAA
set		FTD_Rank = Reference.dbo.tmp1.FTD_Rank,
		FTD_SLSU = Reference.dbo.tmp1.FTD_SLSU,
		FTD_SLSD = Reference.dbo.tmp1.FTD_SLSD
from	Reference.dbo.tmp1
where	Reference.dbo.tmp1.Feature = Reference.dbo.tmpAA.Feature
and		Reference.dbo.tmp1.store_number = Reference.dbo.tmpAA.store_number
and     Reference.dbo.tmp1.sku_number = Reference.dbo.tmpAA.sku_number
--
TRUNCATE TABLE Reference.dbo.tmp2
INSERT INTO Reference.dbo.tmp2
select	t1.feature,
		t2.store_number,
		t2.sku_number,
		sum(t2.current_units) as Week1_SLSU,
		sum(t2.current_dollars) as Week1_SLSD
 from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t1.show_on_report = 1
and		t1.active = 1
and		t2.sku_number = t1.sku_number
and		t2.day_date = staging.dbo.fn_Last_Saturday(getdate())
group by t1.feature,t2.store_number, t2.sku_number
order by t1.feature,sum(t2.current_dollars) desc
--
update	Reference.dbo.tmpAA
set		Wk1_SLSU = Reference.dbo.tmp2.Week1_SLSU,
		Wk1_SLSD = Reference.dbo.tmp2.Week1_SLSD
from	Reference.dbo.tmp2
where	Reference.dbo.tmp2.Feature = Reference.dbo.tmpAA.Feature
and		Reference.dbo.tmp2.store_number = Reference.dbo.tmpAA.store_number
and     Reference.dbo.tmp2.sku_number = Reference.dbo.tmpAA.sku_number
--
-- Get QTD Rank by Feature
--
TRUNCATE TABLE Reference.dbo.tmp3
INSERT INTO Reference.dbo.tmp3
select	t1.Feature,
		t2.store_number,
		t2.sku_number,
		rank () over (partition by t1.Feature order by sum(current_dollars) desc) as QTD_Rank
from	reference.dbo.AA_Feature_Rankings t1 left join 
		dssdata.dbo.weekly_sales t2
on		t1.Promotion = @promo
and		t1.show_on_report = 1
and		t1.active = 1
and		t2.sku_number = t1.sku_number
where	t2.day_date >= @qs
group by t1.Feature,t2.Store_Number,t2.sku_number
order by sum(t2.current_dollars) desc
--
update	Reference.dbo.tmpAA
set		QTD_Rank = Reference.dbo.tmp3.QTD_Rank
from	Reference.dbo.tmp3
where	Reference.dbo.tmp3.store_number = Reference.dbo.tmpAA.store_number
and		Reference.dbo.tmp3.Feature = Reference.dbo.tmpAA.Feature
and		REFERENCE.dbo.tmp3.sku_number= reference.dbo.tmpAA.sku_number
--
Truncate Table 	Reference.dbo.tmp4
INSERT INTO 	Reference.dbo.tmp4
select	t2.store_number,
		t2.sku_number,
		rank () over (order by sum(current_dollars) desc) as TotSls_Rank,
		sum(t2.current_dollars) as SLSD

from	dssdata.dbo.weekly_sales t2
where	t2.day_date >= staging.dbo.fn_Last_Saturday(getdate())
group by store_number, sku_number
order by sum(current_dollars) desc
--
update	Reference.dbo.tmpAA
set		TotSls_Rank = Reference.dbo.tmp4.TotSls_Rank
from	Reference.dbo.tmp4
where	Reference.dbo.tmp4.store_number = Reference.dbo.tmpAA.store_number
and		Reference.dbo.tmp4.sku_number = Reference.dbo.tmpAA.sku_number





--
drop table ReportData.dbo.AA_Feature_Store_Ranking_NEW
--
insert into ReportData.dbo.AA_Feature_Store_Ranking_NEW
select * from Reference.dbo.tmpAA


TRUNCATE TABLE  AA_Feature_Store_Ranking_OnHAND
INSERT INTO  AA_Feature_Store_Ranking_OnHAND

SELECT     AA_Feature_Store_Ranking_NEW.Feature, AA_Feature_Store_Ranking_NEW.Owner, AA_Feature_Store_Ranking_NEW.store_number, 
                      AA_Feature_Store_Ranking_NEW.store_name, AA_Feature_Store_Ranking_NEW.region_number, AA_Feature_Store_Ranking_NEW.district_number, 
                      AA_Feature_Store_Ranking_NEW.FTD_SLSU, AA_Feature_Store_Ranking_NEW.FTD_SLSD, AA_Feature_Store_Ranking_NEW.FTD_Rank, 
                      AA_Feature_Store_Ranking_NEW.WK1_SLSU, AA_Feature_Store_Ranking_NEW.WK1_SLSD, AA_Feature_Store_Ranking_NEW.QTD_Rank, 
                      AA_Feature_Store_Ranking_NEW.TotSls_Rank, AA_Feature_Store_Ranking_NEW.LW_Rank, SUM(Reference.dbo.INVBAL.On_Hand) AS On_Hand

FROM         AA_Feature_Store_Ranking_NEW INNER JOIN
                      Reference.dbo.INVBAL ON AA_Feature_Store_Ranking_NEW.store_number = Reference.dbo.INVBAL.Store_Number AND 
                      AA_Feature_Store_Ranking_NEW.sku_number = Reference.dbo.INVBAL.sku_number
GROUP BY AA_Feature_Store_Ranking_NEW.Feature, AA_Feature_Store_Ranking_NEW.Owner, AA_Feature_Store_Ranking_NEW.store_number, 
                      AA_Feature_Store_Ranking_NEW.store_name, AA_Feature_Store_Ranking_NEW.region_number, AA_Feature_Store_Ranking_NEW.district_number, 
                      AA_Feature_Store_Ranking_NEW.FTD_SLSU, AA_Feature_Store_Ranking_NEW.FTD_SLSD, AA_Feature_Store_Ranking_NEW.FTD_Rank, 
                      AA_Feature_Store_Ranking_NEW.WK1_SLSU, AA_Feature_Store_Ranking_NEW.WK1_SLSD, AA_Feature_Store_Ranking_NEW.QTD_Rank, 
                      AA_Feature_Store_Ranking_NEW.TotSls_Rank, AA_Feature_Store_Ranking_NEW.LW_Rank
GO
