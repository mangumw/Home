USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_AA_Weekly_Summary]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_AA_Weekly_Summary]
as
declare @current_Promotion varchar(50)
declare @current_AA_Num int
declare @i int
declare @tablename varchar(50)
declare @strsql nvarchar(1000)
declare @wk_date smalldatetime
declare @hst_date smalldatetime
--
-- Initialize variables
--
set @i = 0
--
-- Get current Promotion Information
--
select @current_AA_num = Current_AA_Num, @Current_Promotion = Current_Promotion from reference.dbo.aa_Promotions
--
-- Truncate all the work tables
--
Truncate table staging.dbo.wrk_AA_wk1
Truncate table staging.dbo.wrk_AA_wk2
Truncate table staging.dbo.wrk_AA_wk3
Truncate table staging.dbo.wrk_AA_wk4
Truncate table staging.dbo.wrk_AA_wk5
Truncate table staging.dbo.wrk_AA_wk6
Truncate table staging.dbo.wrk_AA_wk7
Truncate table staging.dbo.wrk_AA_wk8
Truncate table staging.dbo.wrk_AA_wk9
Truncate table staging.dbo.wrk_AA_wk10
Truncate table staging.dbo.wrk_AA_wk11
Truncate table staging.dbo.wrk_AA_wk12
--
-- First, build up a list of features and items from history table
--
truncate table reportdata.dbo.AA_Feature_Summary
--
insert into reportdata.dbo.AA_Feature_Summary
select	distinct 
		@Current_Promotion,
		t1.feature,
		t1.sku_number,
		t1.Owner,
		t1.ISBN,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
from	reference.dbo.aa_feature_rankings_history t1
where	t1.promotion = @Current_Promotion
order by feature,sku_number
GO
