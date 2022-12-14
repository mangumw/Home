USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Pvt_Key6]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[usp_Build_Pvt_Key6]
as
--
declare @strsql Nvarchar(1500)
declare @store_number int
declare @sku_out int
declare @rank int
--
-- Drop tmp and result tables
--
if exists(select * from Staging.dbo.sysobjects where Name = 'OSS_Key6_LT1' and  XType = 'U')
  drop table ReportData.dbo.OSS_Key6_LT1 
if exists(select * from Staging.dbo.sysobjects where Name = 'OSS_Key6_LT6' and XType = 'U')
  drop table ReportData.dbo.OSS_Key6_LT6
if exists(select * from Staging.dbo.sysobjects where Name = 'OSS_Key6_LT12' and XType = 'U')
  drop table ReportData.dbo.OSS_Key6_LT12
if exists(select * from ReportData.dbo.sysobjects where Name = 'Pvt_Key16_LT1' and  XType = 'U')
  drop table ReportData.dbo.Pvt_Key6_LT1 
if exists(select * from Staging.dbo.sysobjects where Name = 'Pvt_Key16_LT6' and XType = 'U')
  drop table ReportData.dbo.Pvt_Key6_LT6
if exists(select * from Staging.dbo.sysobjects where Name = 'Pvt_Key16_LT12' and XType = 'U')
  drop table ReportData.dbo.Pvt_Key6_LT12

----
---- Load Key 6 tmp data
----
select	t1.Key_Number,
			t1.Rank,
			t1.Sku_Number,
			t3.Store_Number 
into		ReportData.dbo.OSS_Key6_LT1
from		ReportData.dbo.NonBook_Tops t1,
			Reference.dbo.NonBookStore t2,
			Reference.dbo.INVBAL t3
where		t3.Sku_Number = t1.sku_number
and		t3.store_number = t2.store_number
and		t3.on_hand < 1
and		key_number = 6
order by	t1.Rank

select	t1.Key_Number,
			t1.Rank,
			t1.Sku_Number,
			t3.Store_Number 
into		ReportData.dbo.OSS_Key6_lt6
from		ReportData.dbo.Nonbook_Tops t1,
			Reference.dbo.NonBookStore t2,
			Reference.dbo.INVBAL t3
where		t3.Sku_Number = t1.sku_number
and		t3.store_number = t2.store_number
and		t3.on_hand < 6
and		key_number = 6
order by	t1.Rank

select	t1.Key_Number,
			t1.Rank,
			t1.Sku_Number,
			t3.Store_Number 
into		ReportData.dbo.OSS_Key6_LT12
from		ReportData.dbo.nonbook_tops t1,
			Reference.dbo.NonBookStore t2,
			Reference.dbo.INVBAL t3
where		t3.Sku_Number = t1.sku_number
and		t3.store_number = t2.store_number
and		t3.on_hand < 12
and		t1.Key_number = 6
order by	t1.Rank
--
-- Create Pivot table with SKU Columns and Store # Rows for LT1
--
declare cursql cursor for select distinct(sku_number),Rank from ReportData.dbo.NonBook_Tops where key_number = 6 order by Rank
open cursql
select @strsql = 'Create Table ReportData.dbo.pvt_Key6_LT1 (Store_Number int NULL'
fetch next from cursql into @sku_out,@Rank
while @@fetch_status = 0
begin
	select @strsql = @strsql + ',S' + ltrim(str(@sku_out)) + ' char null'
	fetch next from cursql into @sku_out,@Rank
end
select @strsql = @strsql + ')'
exec sp_executesql @strsql
close cursql
deallocate cursql
--
-- Load all appropriate Store #'s into Pivot Table
--
insert into ReportData.dbo.pvt_Key6_lt1
select distinct(Store_Number),' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' from ReportData.dbo.OSS_Key6_LT1
--
-- Update Pivot Table to put X into intersection between Sku and Store
--
declare cursql cursor for select distinct Store_Number,sku_number from ReportData.dbo.OSS_Key6_lt1
open cursql
fetch next from cursql into @store_number,@sku_out

while @@Fetch_Status = 0
begin
select @strsql = 'update ReportData.dbo.pvt_key6_lt1 set S'
select @strSql = @strsql + ltrim(str(@sku_out)) + '=''X'' where store_number = ' + ltrim(str(@store_number))
--
execute sp_executesql @strsql
--
fetch next from cursql into @store_number,@sku_out
--
end
close cursql
deallocate cursql
--
--
-- Create Pivot table with SKU Columns and Store # Rows for LT6
--
declare cursql cursor for select distinct(sku_number),Rank from ReportData.dbo.NonBook_Tops where key_number = 6 order by Rank
open cursql
select @strsql = 'Create Table ReportData.dbo.pvt_Key6_LT6 (Store_Number int NULL'
fetch next from cursql into @sku_out,@rank
while @@fetch_status = 0
begin
	select @strsql = @strsql + ',S' + ltrim(str(@sku_out)) + ' char null'
	fetch next from cursql into @sku_out,@Rank
end
select @strsql = @strsql + ')'
exec sp_executesql @strsql
close cursql
deallocate cursql
--
-- Load all appropriate Store #'s into Pivot Table
--
insert into ReportData.dbo.pvt_Key6_lt6
select distinct(Store_Number),' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' from ReportData.dbo.OSS_Key6_LT6
--
-- Update Pivot Table to put X into intersection between Sku and Store
--
declare cursql cursor for select distinct Store_Number,sku_number from ReportData.dbo.OSS_Key6_lt6
open cursql
fetch next from cursql into @store_number,@sku_out

while @@Fetch_Status = 0
begin
select @strsql = 'update ReportData.dbo.pvt_key6_lt6 set S'
select @strSql = @strsql + ltrim(str(@sku_out)) + '=''X'' where store_number = ' + ltrim(str(@store_number))
--
execute sp_executesql @strsql
--
fetch next from cursql into @store_number,@sku_out
--
end
close cursql
deallocate cursql
--
--
-- Create Pivot table with SKU Columns and Store # Rows for LT12
--
declare cursql cursor for select distinct(sku_number),Rank from ReportData.dbo.NonBook_Tops where key_number = 6 Order by Rank
open cursql
select @strsql = 'Create Table ReportData.dbo.pvt_Key6_LT12 (Store_Number int NULL'
fetch next from cursql into @sku_out,@Rank
while @@fetch_status = 0
begin
	select @strsql = @strsql + ',S' + ltrim(str(@sku_out)) + ' char null'
	fetch next from cursql into @sku_out,@Rank
end
select @strsql = @strsql + ')'
exec sp_executesql @strsql
close cursql
deallocate cursql
--
-- Load all appropriate Store #'s into Pivot Table
--
insert into ReportData.dbo.pvt_Key6_lt12
select distinct(Store_Number),' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' from ReportData.dbo.OSS_Key6_LT12
--
-- Update Pivot Table to put X into intersection between Sku and Store
--
declare cursql cursor for select distinct Store_Number,sku_number from ReportData.dbo.OSS_Key6_lt12
open cursql
fetch next from cursql into @store_number,@sku_out

while @@Fetch_Status = 0
begin
select @strsql = 'update ReportData.dbo.pvt_key6_lt12 set S'
select @strSql = @strsql + ltrim(str(@sku_out)) + '=''X'' where store_number = ' + ltrim(str(@store_number))
--
execute sp_executesql @strsql
--
fetch next from cursql into @store_number,@sku_out
--
end
close cursql
deallocate cursql












GO
