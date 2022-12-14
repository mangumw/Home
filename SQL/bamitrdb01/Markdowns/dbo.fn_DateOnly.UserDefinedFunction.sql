USE [Markdowns]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DateOnly]    Script Date: 08/23/2022 14:30:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[fn_DateOnly] (@in_date datetime)  
RETURNS smalldatetime AS  
BEGIN 


declare @hr int
declare @mn int
declare @ss int

select @hr = datepart(hh,@in_date)
select @mn = datepart(mi,@in_date)
select @ss = datepart(ss,@in_date)

select @in_date = dateadd(hh,-@hr,@in_date)
select @in_date = dateadd(mi,-@mn,@in_date)
select @in_date = dateadd(ss,-@ss,@in_date)

return @in_date



/*
DECLARE @date_str varchar(25)
DECLARE @year varchar(5)
DECLARE @month VARCHAR(3)
DECLARE @day varchar(3)
DECLARE @ReturnDate SmallDateTime

select @year = ltrim(str(datepart(year,@in_date)))
select @month =  ltrim(str(datepart(month,@in_date)))
select @day = ltrim(str(datepart(day,@in_date)))

select @date_str = @year

if len(@month)= 1
  select @date_str = @date_str + '-0' + @month
else 
  select @date_str = '/' + @date_str + @month

if len(@day)= 1
  select @date_str = @date_str + '-0' + @day
else 
  select @date_str = @date_str + '/' + @day

select @date_str = @date_str + ' 00:00:00'

select @ReturnDate = convert(smalldatetime,@date_str)

return @ReturnDate
*/

END
GO
