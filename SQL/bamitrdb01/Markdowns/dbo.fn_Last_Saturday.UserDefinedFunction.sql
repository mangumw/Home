USE [Markdowns]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Last_Saturday]    Script Date: 08/23/2022 14:30:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Last_Saturday] (@from_date smalldatetime)
returns smalldatetime
begin

declare @fiscal_Week int
declare @fiscal_year int
declare @Last_Saturday smalldatetime

select @from_Date = dbo.fn_DateOnly(@from_date)

select @fiscal_week = fiscal_year_week from calendar_dim where day_date = @From_Date
select @fiscal_year = fiscal_year from calendar_dim where day_date = @From_Date
if @fiscal_week > 1 select @fiscal_week = @fiscal_week - 1
else
begin
  select @fiscal_year = @fiscal_year - 1
  select @fiscal_week = max(fiscal_year_week) from calendar_dim where fiscal_year = @fiscal_year
end

select @Last_Saturday = day_date from calendar_dim where fiscal_year_week = @fiscal_week and day_of_week_number = 7 and fiscal_year = @fiscal_year

return @Last_Saturday
end
GO
