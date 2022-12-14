USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_10_By_Store]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_10_By_Store]
as
--
declare @ReportOrder int
declare @numrows int
declare @Section varchar(30)
declare @Dept_Op varchar(5)
declare @Dept varchar(30)
declare @SDept_Op varchar(5)
declare @SDept varchar(30)
declare @Class_Op varchar(5)
declare @Class varchar(30)
declare @Over_POS Int
declare @year int
declare @week int
declare @Perc_To_Total float
declare @Perc_Remaining float
declare @Year_Build float
declare @Week_Build float
declare @sd smalldatetime
declare @ed smalldatetime
declare @type varchar(10)
declare @CWeek int
declare @build float
declare @BookMult float
declare @NonBookMult float
declare @Mult float
--
declare @sql nvarchar(1500)


--
select @year = datepart(yy,getdate())
select @sd = min(day_date) from reference.dbo.calendar_Dim where calendar_year = @year
select @ed = Max(day_date) from reference.dbo.calendar_Dim where calendar_year = @year
select @ed = staging.dbo.fn_Last_Saturday(@ed)
select @year = @year - 1
select @week = fiscal_year_week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(Getdate())
select @CWeek = Calendar_Week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
GO
