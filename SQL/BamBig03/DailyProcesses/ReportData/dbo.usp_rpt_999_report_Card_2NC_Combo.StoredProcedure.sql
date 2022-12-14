USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_999_report_Card_2NC_Combo]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_rpt_999_report_Card_2NC_Combo] 
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
	@VIN varchar(20),
--	@IFLDSC varchar(35),
	@AAC varchar(5),
	@Strength varchar(5),
	@Buyer varchar(30),
	@AAMaster varchar(50),
	@Season varchar(6),
	@Planner varchar(30),
	@Sort_Order varchar(10),
	@Feature varchar(255),
	@Subject varchar(6),
	@Condition varchar(20)
AS
	SET NOCOUNT ON;
--
declare @strsql nvarchar(4000)
if @numrows <> '<All>'
begin
	select @strsql = 'set rowcount '
	select @strsql = @strsql + @NumRows 
	select @strsql = @strsql + ' select t1.ISBN,'
end
else
select @strsql = ' select t1.ISBN,'
select @strsql = @strsql + 't1.Sku_Number,'
select @strsql = @strsql + 't1.Condition,'
select @strsql = @strsql + 't1.Title,'
select @strsql = @strsql + 't1.Pub_Code,'
select @strsql = @strsql + 't1.Subject,'
select @strsql = @strsql + 't1.Author,'
select @strsql = @strsql + 't1.Sr_Buyer,'
select @strsql = @strsql + 't1.Buyer,'
select @strsql = @strsql + 'ltrim(str(t1.Dept)) + '' / '' + rtrim(t1.SDept_Name) + '' / '' + rtrim(t1.Class_Name) + '' / '' + rtrim(t1.SClass_Name) as Category,'
select @strsql = @strsql + 't1.Dept,'
select @strsql = @strsql + 't1.SDept_Name,'
select @strsql = @strsql + 't1.Class_Name,'
select @strsql = @strsql + 't1.SClass_Name,'
select @strsql = @strsql + 't1.Sku_Type, '
select @strsql = @strsql + 't1.Bowkerstatus, '
select @strsql = @strsql + 't1.Retail, '
select @strsql = @strsql + 't1.Disposition, '
select @strsql = @strsql + 't1.IDate, '
select @strsql = @strsql + 't1.ExpReceiptDate, '
select @strsql = @strsql + 't1.Coordinate_Group, '
select @strsql = @strsql + 't1.Module, '
select @strsql = @strsql + 't1.DWCost, '
select @strsql = @strsql + 't1.Store_Min, '
select @strsql = @strsql + 't1.BAM_OnHand, '
select @strsql = @strsql + 't1.Warehouse_OnHand, '
select @strsql = @strsql + 't1.Qty_OnOrder, '
select @strsql = @strsql + 't1.Qty_OnBackorder, '
select @strsql = @strsql + 't1.ReturnCenter_OnHand, '
select @strsql = @strsql + 't1.InTransit, '
select @strsql = @strsql + 't1.Total_OnHand, '
select @strsql = @strsql + 't1.Week1Units, '
select @strsql = @strsql + 't1.Week1Dollars, '
select @strsql = @strsql + 't1.Week2Units, '
select @strsql = @strsql + 't1.Week2Dollars, '
select @strsql = @strsql + 't1.Week3Units, '
select @strsql = @strsql + 't1.Week3Dollars, '
select @strsql = @strsql + 't1.TYYTDUnits, '
select @strsql = @strsql + 't1.TYYTDDollars, '
select @strsql = @strsql + 't1.LYYTDUnits, '
select @strsql = @strsql + 't1.LYYTDDollars, '
select @strsql = @strsql + 't1.Week13Units, '
select @strsql = @strsql + 't1.Week13Dollars, '
select @strsql = @strsql + 't1.WTD_Units, '
select @strsql = @strsql + 't1.WTD_Dollars, '
select @strsql = @strsql + 't2.display_min AS Display_min_2NC, '
select @strsql = @strsql + 't2.Onhand_2NC, '
select @strsql = @strsql + 't2.Depot_OH, '
select @strsql = @strsql + 't2.OnOrder_2NC, '
select @strsql = @strsql + 't2.Depot_OnOrder, '
select @strsql = @strsql + 't2.Qty_OnOrder AS Qty_OnOrder_2NC, '
select @strsql = @strsql + 't2.Qty_OnBackorder AS Qty_OnBackorder_2NC, '
select @strsql = @strsql + 't2.InTransit AS  InTransit_2NC, '
select @strsql = @strsql + 't2.Depot_InTransit, '
select @strsql = @strsql + 't2.Week1Units AS  Week1Units_2NC, '
select @strsql = @strsql + 't2.Week1Dollars AS  Week1Dollars_2NC, '
select @strsql = @strsql + 't2.Week2Units AS  Week2Units_2NC, '
select @strsql = @strsql + 't2.Week2dollars AS  Week2Dollars_2NC, '
select @strsql = @strsql + 't2.Week3units AS  Week3Units_2NC, '
select @strsql = @strsql + 't2.Week3dollars AS  Week3Dollars_2NC, '
select @strsql = @strsql + 't2.Week13units AS  Week13Units_2NC, '
select @strsql = @strsql + 't2.Week13dollars AS  Week13Dollars_2NC, '
select @strsql = @strsql + 't2.TYYTDUnits AS  TYYTDUnits_2NC, '
select @strsql = @strsql + 't2.TYYTDDollars AS  TYYTDDollars_2NC, '
select @strsql = @strsql + 't2.LYYTDUnits AS  LYYTDUnits_2NC, '
select @strsql = @strsql + 't2.LYYTDDollars AS  LYYTDDollars_2NC, '
select @strsql = @strsql + 't2.Week13units AS  Week13Units_2NC, '
select @strsql = @strsql + 't2.week13dollars AS  Week13Dollars_2NC, '
select @strsql = @strsql + 't2.wtd_Units AS  WTD_Units_2NC, '
select @strsql = @strsql + 't2.wtd_Dollars AS  WTD_Dollars_2NC, '
select @strsql = @strsql + 't2.ltd_units AS  LTD_units_2NC, '
select @strsql = @strsql + 't2.ltd_units AS  LTD_Dollars_2NC '
select @strsql = @strsql + 'FROM Dssdata.dbo.CARD t1  INNER JOIN '
select @strsql = @strsql + 'Dssdata.dbo.card_2NC t2 '
select @strsql = @strsql + 'ON	t1.Sku_number = t2.SKU '


if @Dept = '<All>'
	select @strsql = @strsql + 'where  t1.Dept like ' + '''' + '%' + ''''
else
	select @strsql = @strsql + 'where  t1.Dept = ' + ltrim(str(cast(@dept as int)))

--
if @Feature <> '<All>'
	select @strsql = @strsql + ' and  t1.sku_number in (select sku_number from reference.dbo.aa_feature_rankings where Feature = ''' + @Feature + ''')'
--
if @Sub_Dept <> '<All>'
	select @strsql = @strsql + ' and  t1.SDept = ' + ltrim(str(cast(@Sub_Dept as int)))
--
if @Class <> '<All>'
	select @strsql = @strsql + ' and  t1.Class = ' + ltrim(str(cast(@Class as int)))
--
if @Sub_Class <> '<All>'
	select @strsql = @strsql + ' and  t1.SClass = ' + ltrim(str(cast(@Sub_Class as int)))
--
if @Coordinate_Group <> '<All>'
  select @strsql = @strsql + ' and  t1.Coordinate_Group = ''' + @Coordinate_Group + ''''
--
if @Subject <> '<All>'
  select @strsql = @strsql + ' and  t1.Subject = ''' + @Subject + ''''
--
if @VIN <> '<All>'
  select @strsql = @strsql + ' and  t1.VIN = ' + @VIN 
--
if @Season <> '<All>'
  select @strsql = @strsql + ' and  t1.Season = ''' + @Season + ''''
--
--if @Item_Publisher <> '<All>'
--  select @strsql = @strsql + ' and left(Publisher,30) = ''' + @Item_Publisher + ''''
--
if @sku_type <> 'All'
  select @strsql = @strsql + ' and  t1.sku_type in (select sku_Type from reference.dbo.sku_type_groups where sku_group = ''' + @sku_type + ''')'
--
if @planner <> '<All>'
  select @strsql = @strsql + ' and  t1.Buyer_Number in (select Buyer_Number from reference.dbo.Buyer_Planner_XRef where Planner = ''' + @Planner + ''')'
--
--if @IFLDSC <> '<All>'
--  select @strsql = @strsql + ' and Merch_Group in (select IFINLN from reference.dbo.INVFIN where IFLDSC = ''' + @IFLDSC + ''')'
--
if @PubGroup <> '<All>'
  select @strsql = @strsql + ' and  t1.Pub_Code in (select pub from reference.dbo.Pub_Group where Pub_Grp = ' + '''' + @PubGroup + '''' + ') '
else
  if @Pub_Code <> '<All>'
    select @strsql = @strsql + ' and  t1.Pub_Code = ''' + @Pub_Code + ''''
--
if @Sr_Buyer <> '<All>'
  select @strsql = @strsql + ' and  t1.Sr_Buyer = ''' + @Sr_Buyer + ''''
--
if @Buyer <> '<All>'
  select @strsql = @strsql + ' and  t1.Buyer = ''' + @Buyer + ''''

if @AAC <> '<All>'
  select @strsql = @strsql + ' and  t1.Module = ''' + @AAC + ''''
--
if @AAMaster <> '<All>'
  select @strsql = @Strsql + ' and  t1.Module in (select FDAACODE from reference.dbo.AAMaster where Master_Code = ' + '''' + @AAMaster + '''' + ') '
--
if @Strength <> '<All>'
  select @strsql = @strsql + ' and  t1.Strength = ''' + @Strength + ''''
--
if @Condition <> '<All>'
  select @strsql = @strsql + ' and  t1.Condition = ''' + @Condition + ''''
--
if @Sort_Order = 'WK1D'
  select @strsql = @strsql + ' order by t1.Week1Dollars desc, t1.Sr_Buyer,Buyer,t1.Dept, t1.SDept, t1.Class, t1.SClass, t1.sku_Type'
if @Sort_Order = 'WK1U'
  select @strsql = @strsql + ' order by t1.Week1Units desc, t1.Sr_Buyer,t1.Buyer,t1.Dept, t1.SDept, t1.Class, t1.SClass, t1.sku_Type'
if @Sort_Order = 'WTDD'
  select @strsql = @strsql + ' order by t1.WTD_Dollars desc, t1.Sr_Buyer,t1.Buyer,t1.Dept, t1.SDept, t1.Class, t1.SClass, t1.sku_Type'
if @Sort_Order = 'WTDU'
  select @strsql = @strsql + ' order by t1.WTD_Units desc, t1.Sr_Buyer,t1.Buyer,t1.Dept, t1.SDept, t1.Class, t1.SClass, t1.sku_Type'



EXEC sp_executesql @strsql
GO
