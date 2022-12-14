USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_dsr_report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_build_dsr_report]
AS 
declare @yesterday as smalldatetime
set @yesterday = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
--

insert into staging.dbo.DSR_Detail
select      
            sum(extended_price) as Detail_Price
from  dssdata.dbo.detail_transaction_history
where day_date = @yesterday
and         transaction_code NOT in ('44','DO', '45', '81', '82', '83', 'FP','41','39')
and			store_number > 055

--
insert into staging.dbo.DSR_Detail
select  sum(extended_price) as Other_Price
from  dssdata.dbo.other_transaction_history
where day_date = @yesterday
and         transaction_code <> 'VS'
and			store_number > 055

--
truncate table reportdata.dbo.dsr_detail_report
insert into reportdata.dbo.dsr_detail_report
select      sum(t1.Detail_Price) as Extended_Price
from  staging.dbo.DSR_Detail t1
GO
