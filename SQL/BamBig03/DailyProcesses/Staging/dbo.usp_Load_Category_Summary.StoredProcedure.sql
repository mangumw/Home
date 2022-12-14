USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_Category_Summary]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[usp_Load_Category_Summary]
as
--
declare @Seldate smalldatetime
declare @yr int
declare @wk int
--
select @seldate = max(day_date) from dssdata.dbo.weekly_sales
--
select @yr = fiscal_year,@wk = fiscal_year_week from reference.dbo.calendar_dim where day_date = @seldate
--
insert into DssData.dbo.Category_Summary
select	@yr as Year,
		@wk as Week,
		t2.Dept,
		t2.Sub_Dept as SDept,
		t2.Class as Class,	
		t2.Sub_Class as SClass,
		sum(t1.current_dollars) as WkDollars
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.item_master t2,
		Staging.dbo.Comp_Stores t3
where	t1.sku_number = t2.sku_number		
and		t1.day_date = @seldate
and		t1.store_number = t3.store
group by t2.Dept,t2.Sub_Dept,t2.Class,t2.Sub_Class
order by t2.Dept,t2.Sub_Dept,t2.Class,t2.Sub_Class








GO
