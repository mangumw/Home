USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Misc_Scans_By_Cashier]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Misc_Scans_By_Cashier]
as
declare @StartDate datetime
declare @EndDate datetime

select @EndDate = staging.dbo.fn_Last_Saturday(getdate())
select @StartDate = dateadd(dd,-6,@EndDate)

truncate table tmp_MiscScan_Work

insert into tmp_MiscScan_Work
 select		s.store_number, 
			i.dept, 
			ht.cashier_number, 
			i.sku_type, 
			sum(dt.item_quantity) as units_sold,
			sum(dt.extended_price) as extended_price
 from		dssdata.dbo.Detail_Transaction_Period dt inner join dssdata.dbo.Header_Transaction ht
			on dt.day_date = ht.day_date 
			and dt.store_number = ht.store_number
			and dt.register_nbr = ht.register_number 
			and dt.transaction_nbr = ht.transaction_number
 inner join reference.dbo.Item_Master i 
			on dt.sku_number = i.sku_number
 inner join reference.dbo.Active_Stores s 
			on dt.store_number = s.store_number
 where		s.store_number between 102 and 985
 and		i.dept in (1,2,3,4,5,6,8,10,12,16,69) 
 and		dt.day_date between @StartDate and @EndDate
 and		dt.register_nbr < 900 and ht.cashier_number <> 99998
 group by	s.store_number, i.dept, ht.cashier_number, i.sku_type
--
truncate table tmp_MiscScan
insert into tmp_miscscan
select store_number, dept, cashier_number, sum(units_sold) as units_sold, sum(extended_price) as ext_price,
 sum(case when sku_type = 'M' then units_sold else 0 end) as misc_units_sold,
 sum(case when sku_type = 'M' then extended_price else 0 end) as misc_ext_price
from tmp_MiscScan_Work
 group by store_number, dept, cashier_number


GO
