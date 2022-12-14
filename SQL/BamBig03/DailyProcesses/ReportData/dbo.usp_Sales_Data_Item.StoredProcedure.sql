USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Sales_Data_Item]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Sales_Data_Item]
	@rows varchar(6),
	@sd varchar(15),
	@ed varchar(15),
	@dept varchar(6),
	@sdept varchar(6),
	@class varchar(6),
	@sclass varchar(6),
	@sr_buyer varchar(30),
	@buyer varchar(30),
	@sort varchar(25)
as
--
--
--
declare @sql nvarchar(1000)
--
if @rows <> '<All>'
	SET @sql = 'Select Top ' + @rows + ' t2.sr_buyer, '
else
	set @sql = 'select t2.sr_buyer, '

set @sql = @sql + 't2.buyer, '
set @sql = @sql + 't2.sku_number, '
set @sql = @sql + 't2.isbn, '
set @sql = @sql + 't2.title, '
set @sql = @sql + 't2.dept, '
set @sql = @sql + 't2.sdept, '
set @sql = @sql + 't2.class, '
set @sql = @sql + 't2.sclass, '
set @sql = @sql + 'sum(t1.current_dollars) as SLSD, '
set @sql = @sql + 'sum(t1.current_units) as SLSU '
set @sql = @sql + 'from	dssdata.dbo.weekly_sales t1, '
set @sql = @sql + '		dssdata.dbo.card t2 '
set @sql = @sql + 'where t1.day_date >= ' + '''' + @sd + '''' + ' and t1.day_date <= ' + '''' + @ed + '''' + ' '
if @sr_buyer <> '<All>'
  set @sql = @sql + 'and t2.sr_buyer = ' + '''' + @sr_buyer + '''' + ' '
if @buyer <> '<All>'
  set @sql = @sql + 'and t2.buyer = ' + '''' + @buyer + '''' + ' '
if @dept <> '<All>'
  set @sql = @sql + 'and t2.dept = ' + @dept + ' '
if @sdept <> '<All>'
  set @sql = @sql + 'and t2.sdept = ' + @sdept + ' '
if @class <> '<All>'
  set @sql = @sql + 'and t2.class = ' + @class + ' '
if @sclass <> '<All>'
  set @sql = @sql + 'and t2.sclass = ' + @sclass + ' '
set @sql = @sql + 'and t1.sku_number = t2.sku_number '
set @sql = @sql + 'group by t2.sr_buyer,t2.buyer,t2.sku_number,t2.isbn,t2.title,'
set @sql = @sql + 't2.dept,t2.sdept,t2.class,t2.sclass '
set @sql = @sql + 'order by t2.sr_buyer,t2.buyer,'
if @sort = 'SLS Dollars'
set @sql = @sql + 'sum(t1.current_dollars) desc'
if @sort = 'SLS Units'
set @sql = @sql + 'sum(t1.current_units) desc'
--
--select @sql

exec sp_executesql @sql






GO
