USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Sales_By_Date_Range]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[rpt_Sales_By_Date_Range]
@Start_Date smalldatetime,
@End_Date smalldatetime,
@Dept varchar(6),
@sku_number varchar(10),
@ISBN varchar(20),
@Pub_Code varchar(6),
@Store_Number varchar(6)
as
declare @strsql nvarchar(1000)
select @strsql = 'Select t1.Store_Number,t1.Sku_Number,t1.ISBN,t2.Title,'
select @strsql = @Strsql + 'str(t2.Dept) + ''/'' + rtrim(t2.sdept_name) + ''/'' + rtrim(t2.class_name) + ''/'' + rtrim(t2.sclass_name) as Category, '
select @strsql = @Strsql + 't2.POS_Price, t2.PubCode, ' + '''' + cast(@Start_Date as varchar(40)) + '''' + ' as StartDate, '
select @strsql = @Strsql + '''' + cast(@End_Date as varchar(40)) + '''' + ' as EndDate, sum(t1.Item_Quantity) as SLSU,'
select @strsql = @Strsql + 'sum(t1.Extended_Price) as SLSD '
select @strsql = @Strsql + 'From dssdata.dbo.detail_transaction_history t1,'
select @strsql = @Strsql + 'reference.dbo.item_master t2 where t1.day_date >= '
select @strsql = @Strsql + '''' + cast(@Start_Date as varchar(40)) + '''' + ' and t1.day_date <= ' + '''' + cast(@End_Date as varchar(40)) + '''' + ' '
select @strsql = @Strsql + 'and t2.sku_number = t1.sku_number '
if @Dept <> '<All>'
  select @strsql = @Strsql + 'and t2.Dept = ' + @Dept + ' '

if @Sku_Number <> '<All>'
  select @strsql = @Strsql + 'and t1.sku_number = ' + @Sku_Number + ' '
if @Store_Number <> '<All>'
  select @strsql = @Strsql + 'and t1.Store_number = ' + @Store_Number + ' '

if @ISBN <> '<All>'
  select @strsql = @Strsql + 'and t1.ISBN = ' + '''' + @ISBN + '''' + ' '
if @Pub_Code <> '<All>'
  select @strsql = @Strsql + 'and t2.PubCode = ' + '''' + @Pub_Code + '''' + ' '
--
select @strsql = @strsql + 'Group By t1.store_number,t1.sku_number,t1.isbn,t2.title,'
select @strsql = @strsql + 'str(t2.Dept) + ''/'' + rtrim(t2.sdept_name) + ''/'' + rtrim(t2.class_name) + ''/'' + rtrim(t2.sclass_name) ,'
select @strsql = @strsql + 't2.POS_Price,t2.pubcode'
--
EXEC sp_executesql @strsql
--select @strsql

GO
