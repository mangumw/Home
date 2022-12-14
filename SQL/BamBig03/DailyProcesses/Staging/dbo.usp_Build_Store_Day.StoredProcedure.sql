USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Day]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Store_Day]
as
--
declare @SD as smalldatetime
--
set @sd = staging.dbo.fn_dateonly(dateadd(dd,-5,getdate()))
--
truncate table staging.dbo.DSR_Detail
insert into staging.dbo.DSR_Detail
select      day_date,
            sum(extended_price) as Detail_Price
from		dssdata.dbo.detail_transaction_history
where		day_date >= @sd
and         transaction_code NOT in ('44', '45', '81', '82', '83', 'FP','41','39')
group by	day_date
--
truncate table staging.dbo.DSR_Other
insert into staging.dbo.DSR_Other
select      day_date,
            sum(extended_price) as Other_Price
from		dssdata.dbo.other_transaction_history
where		day_date >= @sd
and         transaction_code <> 'VS'
group by	day_date
--
delete from dssdata.dbo.Store_Day where day_date >= @sd
insert into dssdata.dbo.Store_Day
select      t1.day_date,
            t1.Detail_Price + t2.Other_Price as Extended_Price
from		staging.dbo.DSR_Detail t1,
            staging.dbo.DSR_Other t2
where		t2.day_date = t1.day_date

select * from dssdata.dbo.store_day

 
GO
