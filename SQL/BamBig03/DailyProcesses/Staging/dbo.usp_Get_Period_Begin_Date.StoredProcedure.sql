USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_Period_Begin_Date]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[usp_Get_Period_Begin_Date] 
as
declare @fisyear int
declare @fisperiod int
declare @dop int
declare @bop smalldatetime
declare @seldate varchar(12)
declare @mm int
declare @dd int
declare @yy int
declare @fd int

select @fisyear = Fiscal_Year from Reference.dbo.calendar_dim where day_date = dbo.fn_dateonly(getdate())
select @fisperiod = fiscal_period from Reference.dbo.calendar_dim where day_date = dbo.fn_dateonly(getdate())
select @dop = day_of_period from Reference.dbo.calendar_dim where day_date = dbo.fn_dateonly(getdate())
if @dop = 1 select @fisperiod = @fisperiod - 1
if @fisperiod = 0
begin
  select @fisperiod = 12
  select @fisyear = @fisyear - 1
end

select @bop = day_date from Reference.dbo.calendar_dim where Fiscal_year = @fisyear and fiscal_period = @fisperiod and day_of_period = 1

select @yy = datepart(yy,@bop)
select @mm = datepart(mm,@bop)
select @dd = datepart(dd,@bop)
select @yy = @yy - 2000
select @fd = (@yy*10000) + (@mm * 100) + @dd
select @fd as SelDate









GO
