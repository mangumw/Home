USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_NonBook_Data]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--
CREATE Procedure [dbo].[usp_Build_NonBook_Data]
as
Begin
--
declare @num_NB_stores float
declare @num_drink_stores float
declare @seldate smalldatetime
declare @fiscal_week int
declare @fiscal_year int
declare @tmpsku int
--
select @num_NB_stores = count(Store_Number) from Reference.dbo.NonBookStore
select @num_drink_stores = count(Store_Number) from Reference.dbo.Drink_Store

select @seldate = staging.dbo.fn_Last_Saturday(getdate())
--
truncate table ReportData.dbo.NonBook_Tops
--

drop table Staging.dbo.tmp_key
drop table Staging.dbo.tmp_key_out

create table Staging.dbo.tmp_key
		(Rank int NOT NULL identity(1,1),
		 sku_number bigint NOT NULL,
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table Staging.dbo.tmp_key_out
		(Key_Number int NOT NULL,
		 Rank int not null,
		 sku_number int not null,
		 descr varchar(50) null,
		 item_name varchar(50) not null,
		 Author varchar(50) not null,
		 sku_type char not null,
		 StockGT0 int null,
		 StockGT6 int null,
		 StockGT12 int null,
		 StockLT1 int null,
		 StockLT6 int null,
		 StockLT12 int null,
		 PercAt1 float null,
		 PercAt6 float null,
		 PercAt12 float null,
		 TotalOH int null,
		 WarehouseOnHand int null,
		 WarehouseOnOrder int null,
		 WeekSalesDollars money null,
		 WeekSalesUnits int NULL,
		 Load_Date smalldatetime)
--		 
-- Build Key 6 Data
--
insert into Staging.dbo.tmp_key
select top 20 
		t1.sku_number as sku_number,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.NonBookStore t3
where	t1.Store_Number = t3.store_number
and		t2.dept = 6 
and		t2.sku_number = t1.sku_number
and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name
order by sum(current_dollars) desc
--
insert into Staging.dbo.tmp_key_out
select	6 as Key_Number,
		Staging.dbo.tmp_key.Rank,
		Staging.dbo.tmp_key.sku_number,
		Staging.dbo.tmp_key.Class_Name,
		Reference.dbo.item_dim.item_name,
		Reference.dbo.item_dim.author,
		Reference.dbo.item_dim.sku_type,
		(select count(t2.Store_number) 
		 from Reference.dbo.NonBookStore t1 left join 
		 Reference.dbo.INVBAL t2 on t2.store_number = t1.store_number
         and t2.sku_number = Staging.dbo.tmp_key.sku_number
         where sku_number IS NOT NULL
		 and t2.On_Hand > 0) as StockGT0,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2
         where sku_number = Staging.dbo.tmp_key.sku_number
         and t1.Store_Number = t2.Store_Number
		 and On_Hand > 5) as StockGT6,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2
         where sku_number = Staging.dbo.tmp_key.sku_number
         and t1.Store_Number = t2.Store_Number
		 and On_Hand > 11) as StockGT12,
		NULL asStockLT1,
		NULL asStockLT6,
		NULL asStockLT12,
		NULL asPercAt1,
		NULL asPercAt6,
		NULL asPercAt12,
        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
		 where sku_number = Staging.dbo.tmp_key.sku_number),0)
		 as TotalOnHand,
        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
		isnull(Reference.dbo.ITBAL.OnPO,0) as WarehouseOnOrder,
		Staging.dbo.tmp_key.WeekSalesDollars,
		Staging.dbo.tmp_key.WeekSalesUnits,
		getdate() as Load_Date
from	(Staging.dbo.tmp_key  
         left join Reference.dbo.ITBAL  
         on Staging.dbo.tmp_key.sku_number = Reference.dbo.ITBAL.sku_number)
		left join Reference.dbo.item_dim 
		on Reference.dbo.item_dim.sku_number = Staging.dbo.tmp_key.sku_number
where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
order by Rank
--
declare nbcur cursor for select distinct sku_number from staging.dbo.tmp_key_out
open nbcur
FETCH NEXT FROM nbcur into @tmpsku

while @@fetch_status = 0
begin

select @num_nb_stores = count(t1.store_number) 
						from	reference.dbo.invbal t1,
								reference.dbo.nonbookstore t2
						where	t1.store_number = t2.store_number
						and		sku_number = @tmpsku

update Staging.dbo.tmp_key_out
set StockLT1 = @num_NB_stores - StockGT0,
StockLT6 = @num_NB_stores - StockGT6,
StockLT12 = @num_NB_stores - StockGT12,
PercAt1 = (StockGT0 / @num_NB_stores) * 100,
PercAt6 = (StockGT6 / @num_NB_stores) * 100,
PercAt12 = (StockGT12 / @num_NB_stores) * 100
where sku_number = @tmpsku

fetch next from nbcur into @tmpsku

end
close nbcur
deallocate nbcur
--
--
insert into reportData.dbo.NonBook_Tops
select * from Staging.dbo.tmp_key_out
--
truncate table Staging.dbo.tmp_key
truncate table Staging.dbo.tmp_key_out
--
-- Build Key 4 Data
--
--insert into Staging.dbo.tmp_key
--select top 100 
--		t1.sku_number as sku_number,
--		t2.Class_Name as Class_Name, 
--		sum(current_dollars) as WeekSalesDollars,
--		sum(current_units) as WeekSalesUnits
--from	DssData.dbo.Weekly_Sales t1, 
--		Reference.dbo.Item_Master t2,
--		reference.dbo.Active_Stores t3
--where	t2.dept = 4
--and		t1.Store_Number = t3.Store_Number
--and		t2.sku_number = t1.sku_number
--and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
--and		t1.day_date = @seldate
--group by t1.sku_number,t2.Class_Name
--order by sum(current_dollars) desc
----
--insert into Staging.dbo.tmp_key_out
--select	4 as Key_Number,
--		Staging.dbo.tmp_key.Rank,
--		Staging.dbo.tmp_key.sku_number,
--		left(Staging.dbo.tmp_key.Class_Name,20) as Class_Name,
--		Reference.dbo.item_dim.item_name,
--		Reference.dbo.item_dim.author,
--		Reference.dbo.item_dim.sku_type,
--		(select count(t2.Store_number) 
--		 from reference.dbo.active_stores t1,
--         Reference.dbo.INVBAL t2 
--		 where t2.store_number = t1.store_number and  
--		 t2.sku_number = Staging.dbo.tmp_key.sku_number
--         and sku_number IS NOT NULL
--		 and t2.On_Hand > 0) as StockGT0,
--		(select count(t2.Store_number) 
--		 from reference.dbo.active_stores t1, Reference.dbo.INVBAL t2 
--		 where t2.store_number = t1.store_number and 
--         t2.sku_number = Staging.dbo.tmp_key.sku_number
--         and sku_number IS NOT NULL
--		 and t2.On_Hand > 6) as StockGT6,
--		NULL as StockGT12,
--		NULL asStockLT1,
--		NULL asStockLT6,
--		NULL asStockLT12,
--		NULL asPercAt1,
--		NULL asPercAt6,
--		NULL asPercAt12,
--        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
--		 where sku_number = Staging.dbo.tmp_key.sku_number),0)
--		 as TotalOnHand,
--        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
--		isnull(Reference.dbo.ITBAL.OnBackOrder,0) as WarehouseOnOrder,
--		Staging.dbo.tmp_key.WeekSalesDollars,
--		Staging.dbo.tmp_key.WeekSalesUnits,
--		getdate() as Load_Date
--from	(Staging.dbo.tmp_key  
--         left join Reference.dbo.ITBAL  
--         on Staging.dbo.tmp_key.sku_number = Reference.dbo.ITBAL.sku_number)
--		left join Reference.dbo.item_dim 
--		on Reference.dbo.item_dim.sku_number = Staging.dbo.tmp_key.sku_number
--where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
--order by Rank
----
--declare nbcur cursor for select distinct sku_number from staging.dbo.tmp_key_out
--open nbcur
--FETCH NEXT FROM nbcur into @tmpsku
--
--while @@fetch_status = 0
--begin
--
--select @num_nb_stores = count(t1.store_number) 
--						from	reference.dbo.invbal t1,
--								reference.dbo.active_stores t2
--						where	sku_number = @tmpsku
--						and		t1.store_number = t2.store_number
--
--update Staging.dbo.tmp_key_out
--set StockLT1 = @num_NB_stores - StockGT0,
--StockLT6 = @num_NB_stores - StockGT6,
--StockLT12 = @num_NB_stores - StockGT12,
--PercAt1 = (StockGT0 / @num_NB_stores) * 100,
--PercAt6 = (StockGT6 / @num_NB_stores) * 100
----PercAt12 = (StockGT12 / @num_NB_stores) * 100
--where sku_number = @tmpsku
--
--fetch next from nbcur into @tmpsku
--
--end
--close nbcur
--deallocate nbcur
----
--insert into reportData.dbo.NonBook_Tops
--select * from Staging.dbo.tmp_key_out
----
--truncate table Staging.dbo.tmp_key
--truncate table Staging.dbo.tmp_key_out
--
--
-- Build Key 8 Data
--
insert into Staging.dbo.tmp_key
select top 20 
		t1.sku_number as sku_number,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.NonBookStore t3
where	t1.Store_Number = t3.store_number
and		t2.dept = 8
and		t2.sku_number = t1.sku_number
and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name
order by sum(current_dollars) desc
--
insert into Staging.dbo.tmp_key_out
select	8 as Key_Number,
		Staging.dbo.tmp_key.Rank,
		Staging.dbo.tmp_key.sku_number,
		left(Staging.dbo.tmp_key.Class_Name,20),
		Reference.dbo.item_dim.item_name,
		Reference.dbo.item_dim.author,
		Reference.dbo.item_dim.sku_type,
		(select count(t2.Store_number) 
		 from Reference.dbo.NonBookStore t1 left join 
		 Reference.dbo.INVBAL t2 on t2.store_number = t1.store_number
         and t2.sku_number = Staging.dbo.tmp_key.sku_number
         where sku_number IS NOT NULL
		 and t2.On_Hand > 0) as StockGT0,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2
         where sku_number = Staging.dbo.tmp_key.sku_number
         and t1.Store_Number = t2.Store_Number
		 and On_Hand > 5) as StockGT6,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2
         where sku_number = Staging.dbo.tmp_key.sku_number
         and t1.Store_Number = t2.Store_Number
		 and On_Hand > 11) as StockGT12,
		NULL asStockLT1,
		NULL asStockLT6,
		NULL asStockLT12,
		NULL asPercAt1,
		NULL asPercAt6,
		NULL asPercAt12,
        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
		 where sku_number = Staging.dbo.tmp_key.sku_number),0)
		 as TotalOnHand,
        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
		isnull(Reference.dbo.ITBAL.OnBackOrder,0) as WarehouseOnOrder,
		Staging.dbo.tmp_key.WeekSalesDollars,
		Staging.dbo.tmp_key.WeekSalesUnits,
		getdate() as Load_Date
from	(Staging.dbo.tmp_key  
         left join Reference.dbo.ITBAL  
         on Staging.dbo.tmp_key.sku_number = Reference.dbo.ITBAL.sku_number)
		left join Reference.dbo.item_dim 
		on Reference.dbo.item_dim.sku_number = Staging.dbo.tmp_key.sku_number
where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
order by Rank
--

declare nbcur cursor for select distinct sku_number from staging.dbo.tmp_key_out
open nbcur
FETCH NEXT FROM nbcur into @tmpsku

while @@fetch_status = 0
begin

select @num_nb_stores = count(t1.store_number) 
						from	reference.dbo.invbal t1,
								reference.dbo.nonbookstore t2
						where	t1.store_number = t2.store_number
						and		sku_number = @tmpsku
update Staging.dbo.tmp_key_out
set StockLT1 = @num_NB_stores - StockGT0,
StockLT6 = @num_NB_stores - StockGT6,
StockLT12 = @num_NB_stores - StockGT12,
PercAt1 = (StockGT0 / @num_NB_stores) * 100,
PercAt6 = (StockGT6 / @num_NB_stores) * 100,
PercAt12 = (StockGT12 / @num_NB_stores) * 100
where sku_number = @tmpsku

fetch next from nbcur into @tmpsku

end
close nbcur
deallocate nbcur
--
insert into reportData.dbo.NonBook_Tops
select * from Staging.dbo.tmp_key_out
--
truncate table staging.dbo.tmp_key
truncate table staging.dbo.tmp_key_out
--
--
-- Build Key 16 Data
--
insert into Staging.dbo.tmp_key
select top 9 
		t1.sku_number as sku_number,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.Drink_Store t3,
		Reference.dbo.INVBAL t4
where	t1.Store_Number = t3.Store_Number
and		t2.dept = 16 
and		t2.sku_number = t1.sku_number
and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
and		t4.sku_number = t1.sku_number
and     t4.Store_Number = t1.Store_Number
and		t1.day_date = @seldate 
group by t1.sku_number,t2.Class_Name
Having	sum(t4.On_Hand) > 4
order by sum(current_dollars) desc
--
insert into Staging.dbo.tmp_key_out
select	16 as Key_Number,
		Staging.dbo.tmp_key.Rank,
		Staging.dbo.tmp_key.sku_number,
		left(Staging.dbo.tmp_key.Class_Name,20),
		Reference.dbo.item_dim.item_name,
		Reference.dbo.item_dim.author,
		Reference.dbo.item_dim.sku_type,
		NULL as StockGT0,
--		(select count(t1.Store_number) 
--		 from Reference.dbo.INVBAL t1,
--		 Reference.dbo.Drink_Store t2
--         where sku_number = Staging.dbo.tmp_key.sku_number
--         and t1.Store_Number = t2.Store_Number
--		 and On_Hand > 0) as StockGT0,
		NULL as StockGT6,
--		(select count(t1.Store_number) 
--		 from Reference.dbo.INVBAL t1,
--		 Reference.dbo.Drink_Store t2
--         where sku_number = Staging.dbo.tmp_key.sku_number
--         and t1.Store_Number = t2.Store_Number
--		 and On_Hand > 5) as StockGT6,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.Drink_Store t2
         where sku_number = Staging.dbo.tmp_key.sku_number
         and t1.Store_Number = t2.Store_Number
		 and On_Hand > 11) as StockGT12,
		NULL as StockLT1,
		NULL as StockLT6,
		NULL as StockLT12,
		NULL as PercAt1,
		NULL as PercAt6,
		NULL as PercAt12,
        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
		 where sku_number = Staging.dbo.tmp_key.sku_number),0)
		 as TotalOnHand,
        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
		isnull(Reference.dbo.ITBAL.OnBackOrder,0) as WarehouseOnOrder,
		Staging.dbo.tmp_key.WeekSalesDollars,
		Staging.dbo.tmp_key.WeekSalesUnits,
		getdate() as Load_Date
from	(Staging.dbo.tmp_key  
         left join Reference.dbo.ITBAL  
         on Staging.dbo.tmp_key.sku_number = Reference.dbo.ITBAL.sku_number)
		left join Reference.dbo.item_dim 
		on Reference.dbo.item_dim.sku_number = Staging.dbo.tmp_key.sku_number
where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
order by Rank
--
declare nbcur cursor for select distinct sku_number from staging.dbo.tmp_key_out
open nbcur
FETCH NEXT FROM nbcur into @tmpsku

while @@fetch_status = 0
begin

select @num_nb_stores = count(t1.store_number) 
						from	reference.dbo.invbal t1,
								reference.dbo.nonbookstore t2
						where	t1.store_number = t2.store_number
						and		sku_number = @tmpsku

update Staging.dbo.tmp_key_out
set --StockLT1 = @num_drink_stores - StockGT0,
--StockLT6 = @num_drink_stores - StockGT6,
StockLT12 = @num_drink_stores - StockGT12,
--PercAt1 = (StockGT0 / @num_drink_stores) * 100,
--PercAt6 = (StockGT6 / @num_drink_stores) * 100,
PercAt12 = (StockGT12 / @num_drink_stores) * 100
where sku_number = @tmpsku
--
fetch next from nbcur into @tmpsku
--
end
close nbcur
deallocate nbcur
--
insert into reportData.dbo.NonBook_Tops
select * from Staging.dbo.tmp_key_out
--
truncate table Staging.dbo.tmp_key
truncate table Staging.dbo.tmp_key_out
--
-- Build Key 3 Data
--
--insert into Staging.dbo.tmp_key
--select top 20 
--		t1.sku_number as sku_number,
--		t2.Class_Name as Class_Name, 
--		sum(current_dollars) as WeekSalesDollars,
--		sum(current_Units) as WeekSalesUnits
--from	DssData.dbo.Weekly_Sales t1, 
--		Reference.dbo.Item_Master t2,
--		Reference.dbo.NonBookStore t3,
--		Reference.dbo.INVBAL t4
--where	t1.Store_Number = t3.Store_Number
--and		t2.dept = 3 
--and		t2.sku_number = t1.sku_number
--and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
--and		t4.sku_number = t1.sku_number
--and     t4.Store_Number = t1.Store_Number
--and		t1.day_date = @seldate
--and		t2.Vendor_Number = 621   -- AWBC
--group by t1.sku_number,t2.Class_Name
--Having	sum(t4.On_Hand) > 4
--order by sum(current_dollars) desc
----
--insert into Staging.dbo.tmp_key_out
--select	3 as Key_Number,
--		Staging.dbo.tmp_key.Rank,
--		Staging.dbo.tmp_key.sku_number,
--		left(Staging.dbo.tmp_key.Class_Name,20),
--		Reference.dbo.item_dim.item_name,
--		Reference.dbo.item_dim.author,
--		Reference.dbo.item_dim.sku_type,
--		(select count(t1.Store_number) 
--		 from Reference.dbo.INVBAL t1,
--		 Reference.dbo.NonBookStore t2
--       where sku_number = Staging.dbo.tmp_key.sku_number
--       and t1.Store_Number = t2.Store_Number
--		 and On_Hand > 0) as StockGT0,
--		(select count(t1.Store_number) 
--		 from Reference.dbo.INVBAL t1,
--		 Reference.dbo.NonBookStore t2
--         where sku_number = Staging.dbo.tmp_key.sku_number
--         and t1.Store_Number = t2.Store_Number
--		 and On_Hand > 5) as StockGT6,
--		NULL as StockGT12,
----		(select count(t1.Store_number) 
----		 from Reference.dbo.INVBAL t1,
----		 Reference.dbo.NonBookStore t2
----         where sku_number = Staging.dbo.tmp_key.sku_number
----         and t1.Store_Number = t2.Store_Number
----		 and On_Hand > 11) as StockGT12,
--		NULL asStockLT1,
--		NULL asStockLT6,
--		NULL asStockLT12,
--		NULL asPercAt1,
--		NULL asPercAt6,
--		NULL asPercAt12,
--        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
--		 where sku_number = Staging.dbo.tmp_key.sku_number),0)
--		 as TotalOnHand,
--        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
--		isnull(Reference.dbo.ITBAL.OnBackOrder,0) as WarehouseOnOrder,
--		Staging.dbo.tmp_key.WeekSalesDollars,
--		Staging.dbo.tmp_key.WeekSalesUnits,
--		getdate() as Load_date
--from	(Staging.dbo.tmp_key  
--         left join Reference.dbo.ITBAL  
--         on Staging.dbo.tmp_key.sku_number = Reference.dbo.ITBAL.sku_number)
--		left join Reference.dbo.item_dim 
--		on Reference.dbo.item_dim.sku_number = Staging.dbo.tmp_key.sku_number
--where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
--order by Rank
----
--
--declare nbcur cursor for select distinct sku_number from staging.dbo.tmp_key_out
--open nbcur
--FETCH NEXT FROM nbcur into @tmpsku
--
--while @@fetch_status = 0
--begin
--
--select @num_nb_stores = count(t1.store_number) 
--						from	reference.dbo.invbal t1,
--								reference.dbo.nonbookstore t2
--						where	t1.store_number = t2.store_number
--						and		sku_number = @tmpsku
--
--update Staging.dbo.tmp_key_out
--set StockLT1 = @num_NB_stores - StockGT0,
--StockLT6 = @num_NB_stores - StockGT6,
---- StockLT12 = @num_NB_stores - StockGT12,
--PercAt1 = (StockGT0 / @num_NB_stores) * 100,
--PercAt6 = (StockGT6 / @num_NB_stores) * 100
----PercAt12 = (StockGT12 / @num_NB_stores) * 100
--where sku_number = @tmpsku
----
--fetch next from nbcur into @tmpsku
----
--end
--close nbcur
--deallocate nbcur
----
--insert into reportData.dbo.NonBook_Tops
--select * from Staging.dbo.tmp_key_out
----
---- Build OOS Key Report Tables
----
--truncate table ReportData.dbo.OOS_Detail
--
--execute ReportData.dbo.usp_Build_OOS_Key16
--
--execute ReportData.dbo.usp_Build_OOS_Key3
--
--execute ReportData.dbo.usp_Build_OOS_Key6
--
--execute ReportData.dbo.usp_Build_OOS_Key8
--
--execute ReportData.dbo.usp_Build_OOS_Key4
--
end















































GO
