USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_misc_scan_report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_misc_scan_report]
as
declare @End_Date smalldatetime
declare @Week_sd smalldatetime
declare @Period_sd smalldatetime
declare @Year_sd smalldatetime
declare @Fiscal_Period int
declare @Fiscal_Year int
--
select @End_Date = staging.dbo.fn_Last_Saturday(Getdate())
select @Week_sd = dateadd(dd,-6,@End_Date)
select @fiscal_Period = fiscal_period from reference.dbo.calendar_dim where day_date = @End_Date
select @fiscal_Year = fiscal_year from reference.dbo.calendar_dim where day_date = @End_date
select @Period_sd = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_Year and fiscal_Period = @fiscal_period
select @Year_sd = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_Year
--
-- Get Week Numbers
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Week_total
into		#Total_Week
FROM        DssData.dbo.Detail_Transaction_History t1 INNER JOIN
            Reference.dbo.Item_Master t2
ON			t1.Sku_Number = t2.SKU_Number 
			INNER JOIN Reference.dbo.active_stores t3
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Week_sd AND @End_Date)
and			t1.store_number > 55 and t1.register_nbr < 900 
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Week_Misc
into		#Misc_Week
FROM        DssData.dbo.Detail_Transaction_History t1 
INNER JOIN	Reference.dbo.Item_Master t2 
ON			t1.Sku_Number = t2.SKU_Number 
INNER JOIN	Reference.dbo.active_stores t3 
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Week_sd AND @End_Date) 
AND			(t2.SKU_Number IN (1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 69, 58, 13, 14, 16))
and			t1.store_number > 55 and t1.register_nbr < 900 
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name--
-- Get Period Numbers
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Period_total
into		#Total_Period
FROM        DssData.dbo.Detail_Transaction_History t1 INNER JOIN
            Reference.dbo.Item_Master t2
ON			t1.Sku_Number = t2.SKU_Number 
			INNER JOIN Reference.dbo.active_stores t3
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Period_sd AND @End_Date)
and			t1.store_number > 55 and t1.register_nbr < 900 
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Period_Misc
into		#Misc_Period
FROM        DssData.dbo.Detail_Transaction_History t1 
INNER JOIN	Reference.dbo.Item_Master t2 
ON			t1.Sku_Number = t2.SKU_Number 
INNER JOIN	Reference.dbo.active_stores t3 
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Period_sd AND @End_Date) 
AND			(t2.SKU_Number IN (1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 69, 58, 13, 14, 16))
and			t1.store_number > 55 and t1.register_nbr < 900 
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name
--
-- Get Year Numbers
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Year_total
into		#Total_Year
FROM        DssData.dbo.Detail_Transaction_History t1 INNER JOIN
            Reference.dbo.Item_Master t2
ON			t1.Sku_Number = t2.SKU_Number 
			INNER JOIN Reference.dbo.active_stores t3
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Year_sd AND @End_Date)
and			t1.store_number > 55 and t1.register_nbr < 900
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name
--
SELECT		t3.Region_Number,
			t3.District_Number,
			t1.Store_Number, 
			t3.store_name, 
			SUM(t1.Item_Quantity) AS Year_Misc
into		#Misc_Year
FROM        DssData.dbo.Detail_Transaction_History t1 
INNER JOIN	Reference.dbo.Item_Master t2 
ON			t1.Sku_Number = t2.SKU_Number 
INNER JOIN	Reference.dbo.active_stores t3 
ON			t1.Store_Number = t3.store_number
WHERE		(t1.Day_Date BETWEEN @Year_sd AND @End_Date) 
AND			(t2.SKU_Number IN (1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 69, 58, 13, 14, 16))
and			t1.store_number > 55 and t1.register_nbr < 900 
GROUP BY	t3.Region_Number,t3.District_Number,t1.Store_Number, t3.store_name
--
-- Join data together
--
truncate table reportdata.dbo.misc_scan_report
insert into reportdata.dbo.misc_scan_report
SELECT		getdate(),
			t1.Region_Number,
			t1.District_Number,
			t1.Store_Number, 
			t1.store_name, 
            isnull(t1.Year_Total,0) as Year_Total,
			isnull(t2.Year_Misc,0) as Year_Misc,
			isnull(t3.Period_Total,0) as Period_Total,
			isnull(t4.Period_Misc,0) as Period_Misc,
			isnull(t5.Week_Total,0) as Week_Total,
			isnull(t6.Week_Misc,0) as Week_Misc
FROM        #Total_year t1
LEFT JOIN	#Misc_year t2 
ON			t2.Store_Number = t1.Store_Number 
AND			t2.store_name = t1.store_name 
Left Join	#Total_Period t3
ON			t3.Store_Number = t1.Store_Number 
AND			t3.store_name = t1.store_name 
left join	#Misc_Period t4
ON			t4.Store_Number = t1.Store_Number 
AND			t4.store_name = t1.store_name 
left join	#Total_week t5
ON			t5.Store_Number = t1.Store_Number 
AND			t5.store_name = t1.store_name 
left join	#Misc_Week t6
ON			t6.Store_Number = t1.Store_Number 
AND			t6.store_name = t1.store_name 
order by	t1.store_number


drop table #total_week
drop table #misc_week
drop table #total_period
drop table #misc_period
drop table #total_year
drop table #misc_year




GO
