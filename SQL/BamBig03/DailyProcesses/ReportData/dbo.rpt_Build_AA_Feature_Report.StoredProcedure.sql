USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Build_AA_Feature_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[rpt_Build_AA_Feature_Report]
as
declare @sd smalldatetime
declare @wd smalldatetime
declare @Promotion varchar(50)
set @sd = staging.dbo.fn_Last_Saturday(dateadd(dd,-1,getdate()))
set @wd = dateadd(dd,1,@sd)

declare cur cursor for select promotion from reference.dbo.aa_feature_rankings where active = 1
open cur
fetch next from cur into @promotion
close cur
deallocate cur
--
truncate table reportdata.dbo.AA_Feature_Chain
--
insert into	reportdata.dbo.AA_Feature_Chain

select	@promotion,
		row_number()  over (partition by t1.feature order by sum(t3.current_dollars)Desc) as Sort_Rank,
		t1.Feature,
		NULL as Owner,
		t1.Rank,
		t1.ISBN,
		t1.Title,
		t2.sr_buyer,
		t2.Author,
		t2.BAM_OnHand,
		t2.Warehouse_OnHand,
		t2.Qty_OnOrder,
		t2.Retail,
		isnull(t2.Week1Units,0) as wk1_Units,
		isnull(t2.Week1Dollars,0) as wk1_Dollars,
		t1.Projection/8 as wk1_Projection,
		sum(isnull(t3.current_dollars,0)) as FTD_Dollars,
		sum(isnull(t3.current_units,0)) as FTD_Units,
		t1.projection as Feature_Projection,
		0 as WTD_Units,
		0 as WTD_Dollars,
	    t2.Sku_Number as SKU,
		t2.Buyer
from	Reference.dbo.aa_feature_rankings t1 
		left join dssdata.dbo.card t2
		on t2.sku_number = t1.sku_number
		and t1.Show_On_report = 1
		left join dssdata.dbo.weekly_sales t3
		on t3.sku_number = t1.sku_number and t3.day_date >= t1.set_date and t3.day_date <= t1.unset_date
where	t1.active = 1
group by t1.Feature,t1.rank,t1.isbn,t1.title,t2.sr_buyer,t2.author,t2.BAM_OnHand,t2.Warehouse_OnHand,t2.Qty_OnOrder,t2.Retail,t1.projection,t2.Week1Units,t2.Week1Dollars,t1.print_order, t2.Sku_Number, t2.Buyer
order by t1.Feature,sum(t3.current_dollars) desc
--
select	t1.feature as feature,
		t1.isbn as isbn,
		sum(t2.extended_price) as twSLSD,
		sum(t2.item_quantity) as twSLSU
into	#wtd
from	reference.dbo.aa_feature_rankings t1 left join 
		Dssdata.dbo.detail_transaction_period t2
on		t2.sku_number = t1.sku_number
and		t1.Show_On_Report = 1
and		t1.Active = 1
and		t2.day_date >= @wd
group by t1.feature,t1.isbn
--
CREATE NONCLUSTERED INDEX [#idx_wtd] ON #wtd
(
	Feature ASC,
	ISBN asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF)
--
update reportdata.dbo.AA_Feature_Chain
set WTD_Units = twslsu,WTD_Dollars=twslsd
from #wtd
where reportdata.dbo.AA_Feature_Chain.feature = #wtd.feature 
and reportdata.dbo.AA_Feature_Chain.isbn = #wtd.isbn
--
truncate table ReportData.dbo.AA_Feature_Store
--
insert into ReportData.dbo.AA_Feature_Store
select	t1.feature as feature,
		NULL as Owner,
		t2.store_number,
		t3.Store_Name,
		t3.region_number,
		t3.district_number,
		sum(t2.extended_price) as FTD_SLSD,
		sum(t2.item_quantity) as FTD_SLSU,
		0 as Wk1_Dollars,
		0 as Wk1_Units,
		0 as WTD_Dollars,
		0 as WTD_Units
from	reference.dbo.aa_feature_rankings t1,
		dssdata.dbo.detail_transaction_history t2,
		reference.dbo.AA_active_stores t3
where	t2.store_number = t3.store_number
and		t2.day_date >= t1.set_date
and		t2.day_date <= t1.unset_date
and		t2.sku_number = t1.sku_number
and		t1.Show_On_Report = 1
and		t1.active = 1
group by t1.feature,t2.store_number,t3.store_name,t3.region_number,t3.district_number
--
select	t1.feature as feature,
		t1.Owner,
		t2.store_number,
		sum(t2.extended_price) as twSLSD,
		sum(t2.item_quantity) as twSLSU
into	#upd1
from	reference.dbo.aa_feature_rankings t1,
		Dssdata.dbo.detail_transaction_period t2
where	t2.sku_number = t1.sku_number
and		t2.day_date >= @wd
and		t1.Show_On_report = 1
and		t1.active = 1
group by t1.feature,t1.owner,t2.store_number
order by t1.feature,t2.store_number
--
select	t1.feature as feature,
		t2.store_number,
		sum(t2.extended_price) as wk1_SLSD,
		sum(t2.item_quantity) as wk1_SLSU
into	#upd2
from	reference.dbo.aa_feature_rankings t1,
		Dssdata.dbo.detail_transaction_history t2
where	t2.sku_number = t1.sku_number
and		t2.day_date = @sd
and		t1.Show_On_Report = 1
and		t1.active = 1
group by t1.feature,t1.owner,t2.store_number
order by t1.feature,t2.store_number
--
update	ReportData.dbo.AA_Feature_Store
set		wtd_Dollars = twslsd,wtd_Units = twslsu,
		Owner = #upd1.Owner
from	#upd1
where	#upd1.feature = ReportData.dbo.AA_Feature_Store.Feature
and		#upd1.store_number = ReportData.dbo.AA_Feature_Store.Store_Number

--
update	ReportData.dbo.AA_Feature_Store
set		wk1_dollars = wk1_slsd,wk1_units = wk1_slsu
from	#upd2
where	#upd2.feature = ReportData.dbo.AA_Feature_Store.Feature
and		#upd2.store_number = ReportData.dbo.AA_Feature_Store.Store_Number

Truncate table reportdata.dbo.AA_FEATURE_STORE_NEW
Insert INTO		reportdata.dbo.AA_FEATURE_STORE_NEW
SELECT        AA_Feature_Store.feature, AA_Feature_Store.Owner, AA_Feature_Store.store_number, AA_Feature_Store.Store_Name, AA_Feature_Store.Region_Number, AA_Feature_Store.District_Number, 
                         AA_Feature_Store.FTD_Dollars, AA_Feature_Store.FTD_Units, AA_Feature_Store.Wk1_Dollars, AA_Feature_Store.Wk1_Units, AA_Feature_Store.WTD_Dollars, AA_Feature_Store.WTD_Units, 
                         Reference.dbo.AA_OH_STR.On_Hand
FROM            AA_Feature_Store LEFT OUTER JOIN
                         Reference.dbo.AA_OH_STR ON AA_Feature_Store.feature = Reference.dbo.AA_OH_STR.Feature AND AA_Feature_Store.store_number = Reference.dbo.AA_OH_STR.Store_Number
GO
