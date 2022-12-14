USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_dual_range_compare]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_dual_range_compare]
@numrows	char(6) = '50',
@FRStart	varchar(12) = '01-01-2007',
@FREnd		varchar(12) = '01-01-2007',
@SRStart	varchar(12) = '01-02-2006',
@SREnd		varchar(12) = '01-02-2006',
@Dept		char(6) = '01',
@SDept		char(6) = '<All>',
@Class		char(6) = '<All>',
@SClass		char(6) = '<All>',
@Coordinate_Group varchar(6) = '<All>',
@Vin		char(20) = '<All>',
@PubCode	char(6) = '<All>'
AS
--
declare @strsql		nvarchar(1500)
--
------------------------------------
--
select @strsql = 'select ' 
if @numrows <> '<All>'
  select @strsql = @strsql + 'top ' + @numrows 
select @strsql = @strsql + ' t1.day_date,'
select @strsql = @strsql + 't1.sku_number,'
select @strsql = @strsql + 't2.title,'
select @strsql = @strsql + 't2.Author,'
select @strsql = @strsql + 't2.pubcode,'
select @strsql = @strsql + 'sum(t1.extended_price) as extended_price,'
select @strsql = @strsql + '(select sum(item_quantity) from dssdata.dbo.detail_transaction_history '
select @strsql = @strsql + ' where day_date >= ' + '''' + @FRStart + '''' + ' and day_date <= ' + '''' + @FREnd + ''''
select @strsql = @strsql + ' and sku_number = t1.sku_number '
select @strsql = @strsql + ' group by sku_number) as FR_Units,'
select @strsql = @strsql + '(select sum(extended_price) from dssdata.dbo.detail_transaction_history  '
select @strsql = @strsql + ' where day_date >= ' + '''' + @FRStart + '''' + ' and day_date <= ' + '''' + @FREnd + ''''
select @strsql = @strsql + ' and sku_number = t1.sku_number  '
select @strsql = @strsql + ' group by sku_number) as FR_Dollars,'
select @strsql = @strsql + '(select sum(item_quantity) from dssdata.dbo.detail_transaction_history  '
select @strsql = @strsql + ' where day_date >= ' + '''' + @SRStart + '''' + ' and day_date <= ' + '''' + @SREnd + ''''
select @strsql = @strsql + ' and sku_number = t1.sku_number  '
select @strsql = @strsql + ' group by sku_number) as SR_Units,'
select @strsql = @strsql + '(select sum(extended_price) from dssdata.dbo.detail_transaction_history  '
select @strsql = @strsql + ' where day_date >= ' + '''' + @SRStart + '''' + ' and day_date <= ' + '''' + @SREnd + ''''
select @strsql = @strsql + ' and sku_number = t1.sku_number  '
select @strsql = @strsql + ' group by sku_number) as SR_Dollars '
select @strsql = @strsql + ' from dssdata.dbo.detail_transaction_history t1, '
select @strsql = @strsql + '	reference.dbo.item_master t2  '
select @strsql = @strsql + 'where	t2.sku_number = t1.sku_number '
select @strsql = @strsql + 'and		(t2.sku_type = ' + '''' + 'T' + '''' + ' or sku_type = ' + '''' + 'N' + '''' + ' or sku_type = ' + '''' + 'B' + '''' + ')'
select @strsql = @strsql + ' and		t2.Dept = 04     '
select @strsql = @strsql + 'and		t1.day_date = ' + '''' + @FRStart + ''''
if @SDept <> '<All>' 
select @strsql = @strsql + ' and t2.SDept = ' + @SDept
--
if @Class <> '<All>' 
select @strsql = @strsql + ' and t2.Class = ' + @Class
--
if @VIN <> '<All>'
  select @strsql = @strsql + ' and t2.Vendor_Number = ' + @VIN 
--
if @SClass <> '<All>' 
select @strsql = @strsql + ' and t2.SClass = ' + @SClass
--
if @PubCode <> '<All>' 
select @strsql = @strsql + ' and t2.PubCode = ' + @PubCode
--
if @Coordinate_Group <> '<All>' 
select @strsql = @strsql + ' and t2.Coordinate_Group = ' + @Coordinate_Group



select @strsql = @strsql + ' group by t1.day_date,t1.sku_number,t2.title,t2.author,t2.pubcode'
select @strsql = @strsql + ' order by sum(t1.extended_price) desc'
--
------------------------------------------------------------
--
--select @strsql
--
EXEC sp_executesql @strsql
















GO
