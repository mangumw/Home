USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Sales_By_Date_Range_Ext]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mark Redman>
-- Create date: <07-18-2007>
-- Description:	<This is the report data selector for the Sales By Date Range>
-- =============================================
CREATE PROCEDURE [dbo].[rpt_Sales_By_Date_Range_Ext]
	@Start_Date smalldatetime,
	@End_Date smalldatetime, 
	@NumRows varchar(6),
	@Dept char(6),
	@Sub_Dept char(6),
	@Class char(6),
	@Sub_Class char(6),
	@sku_type varchar(25),
	@Coordinate_Group varchar(5),
	@Pub_Code varchar(6),
	@Sr_Buyer varchar(30),
	@PubGroup varchar(6),
--	@VIN varchar(20),
	@AAC varchar(5),
	@Strength varchar(5),
	@Buyer varchar(30),
	@AAMaster varchar(50),
--	@Season varchar(6),
	@Planner varchar(30),
	@Sort_Order varchar(10)
AS
	SET NOCOUNT ON;
--
declare @strsql nvarchar(1000)
if @numrows <> '<All>'
begin
	select @strsql = 'set rowcount '
	select @strsql = @strsql + @NumRows 
    select @strsql = @strsql + ' select t1.sku_number,'

end
else
    select @strsql = ' select t1.sku_number,'
--
select @strsql = @strsql + 't1.ISBN,'
select @strsql = @strsql + 't2.Title,'
select @strsql = @strsql + 'str(t2.Dept) + ''/'' + rtrim(t2.sdept_name) + ''/'' + rtrim(t2.class_name) + ''/'' + rtrim(t2.sclass_name) as Category, '
select @strsql = @strsql + 't2.Retail,'
select @strsql = @strsql + 't2.Pub_Code,'
select @strsql = @strsql + '''' + cast(@Start_Date as varchar(40)) + '''' + ' as StartDate, ' 
select @strsql = @strsql + '''' + cast(@End_Date as varchar(40)) + '''' + ' as EndDate, ' 
select @strsql = @strsql + 'sum(t1.Item_Quantity) as SLSU, sum(t1.Extended_Price) as SLSD '
select @strsql = @Strsql + 'From dssdata.dbo.detail_transaction_history t1,'
select @strsql = @Strsql + 'dssdata.dbo.card t2 where t1.day_date >= '
select @strsql = @Strsql + '''' + cast(@Start_Date as varchar(40)) + '''' + ' and t1.day_date <= ' + '''' + cast(@End_Date as varchar(40)) + '''' + ' '
select @strsql = @Strsql + 'and t2.sku_number = t1.sku_number '

if @Dept <> '<All>'
	select @strsql = @strsql + 'and t2.Dept = ' + ltrim(str(cast(@dept as int)))
--
if @Sub_Dept <> '<All>'
	select @strsql = @strsql + ' and t2.SDept = ' + ltrim(str(cast(@Sub_Dept as int)))
--
if @Class <> '<All>'
	select @strsql = @strsql + ' and t2.Class = ' + ltrim(str(cast(@Class as int)))
--
if @Sub_Class <> '<All>'
	select @strsql = @strsql + ' and t2.SClass = ' + ltrim(str(cast(@Sub_Class as int)))
--
if @Coordinate_Group <> '<All>'
  select @strsql = @strsql + ' and t2.Coordinate_Group = ''' + @Coordinate_Group + ''''
--
--if @VIN <> '<All>'
--  select @strsql = @strsql + ' and VIN = ' + @VIN 
--
--if @Season <> '<All>'
--  select @strsql = @strsql + ' and Season = ''' + @Season + ''''
--
--if @Item_Publisher <> '<All>'
--  select @strsql = @strsql + ' and left(Publisher,30) = ''' + @Item_Publisher + ''''
--
if @sku_type <> 'All'
  select @strsql = @strsql + ' and t2.sku_type in (select sku_Type from reference.dbo.sku_type_groups where sku_group = ''' + @sku_type + ''')'
--
if @planner <> '<All>'
  select @strsql = @strsql + ' and t2.Buyer_Number in (select Buyer_Number from reference.dbo.Buyer_Planner_XRef where Planner = ''' + @Planner + ''')'
--
--if @IFLDSC <> '<All>'
--  select @strsql = @strsql + ' and Merch_Group in (select IFINLN from reference.dbo.INVFIN where IFLDSC = ''' + @IFLDSC + ''')'
--
if @PubGroup <> '<All>'
  select @strsql = @strsql + ' and t2.Pub_Code in (select pub from reference.dbo.Publisher_Group where PubGroup = ' + '''' + @PubGroup + '''' + ') '
else
  if @Pub_Code <> '<All>'
    select @strsql = @strsql + ' and t2.Pub_Code = ''' + @Pub_Code + ''''
--
if @Sr_Buyer <> '<All>'
  select @strsql = @strsql + ' and t2.Sr_Buyer = ''' + @Sr_Buyer + ''''
--
if @Buyer <> '<All>'
  select @strsql = @strsql + ' and t2.Buyer = ''' + @Buyer + ''''

if @AAC <> '<All>'
  select @strsql = @strsql + ' and t2.Module = ''' + @AAC + ''''
--
if @AAMaster <> '<All>'
  select @strsql = @Strsql + ' and t2.Module in (select FDAACODE from reference.dbo.AAMaster where Master_Code = ' + '''' + @AAMaster + '''' + ') '
--
if @Strength <> '<All>'
  select @strsql = @strsql + ' and t2.Strength = ''' + @Strength + ''''
--
select @strsql = @strsql + ' Group By t1.sku_number,t1.isbn,t2.title,'
select @strsql = @strsql + 'str(t2.Dept) + ''/'' + rtrim(t2.sdept_name) + ''/'' + rtrim(t2.class_name) + ''/'' + rtrim(t2.sclass_name) ,'
select @strsql = @strsql + 't2.Retail,t2.pub_code'
--
--if @Sort_Order = 'WK1D'
--  select @strsql = @strsql + ' order by t2Week1Dollars desc, Sr_Buyer,Buyer,Dept, SDept, Class, SClass, sku_Type'
--if @Sort_Order = 'WK1U'
--  select @strsql = @strsql + ' order by Week1Units desc, Sr_Buyer,Buyer,Dept, SDept, Class, SClass, sku_Type'
--if @Sort_Order = 'WTDD'
--  select @strsql = @strsql + ' order by WTD_Dollars desc, Sr_Buyer,Buyer,Dept, SDept, Class, SClass, sku_Type'
--if @Sort_Order = 'WTDU'
--  select @strsql = @strsql + ' order by WTD_Units desc, Sr_Buyer,Buyer,Dept, SDept, Class, SClass, sku_Type'

--
select @strsql
--
--EXEC sp_executesql @strsql
























































































GO
