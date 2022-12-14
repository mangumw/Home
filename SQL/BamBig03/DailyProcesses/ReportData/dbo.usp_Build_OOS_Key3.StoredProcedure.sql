USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_Key3]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--
CREATE Procedure [dbo].[usp_Build_OOS_Key3]
as
Begin
----
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
--truncate table ReportData.dbo.NonBook_Tops
--

drop table Staging.dbo.tmp_key3
drop table ReportData.dbo.NonBook_Data_Key3

create table Staging.dbo.tmp_key3
		(Rank int NOT NULL identity(1,1),
		 sku_number bigint NOT NULL,
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.NonBook_Data_Key3
		(Key_Number int NOT NULL,
		 Rank int not null,
		 Sr_Buyer varchar(30) NULL,
		 sku_number int not null,
		 descr varchar(20) null,
		 title varchar(50) not null,
		 Author varchar(50) not null,
		 pub_code varchar(5),
		 sku_type char not null,
		 StockLT1 int NULL,
		 StockGTM int null,
		 StockLTM int null,
		 PercAt float null,
		 TotalOH int null,
		 WarehouseOnHand int null,
		 WarehouseOnOrder int null,
		 WeekSalesDollars money null,
		 WeekSalesUnits int NULL,
		 Load_Date smalldatetime)
--
-- Build Key 3 Data
--
insert into Staging.dbo.tmp_key3
select top 20 
		t1.sku_number as sku_number,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.NonBookStore t3,
		Reference.dbo.INVBAL t4
where	t1.Store_Number = t3.Store_Number
and		t2.dept = 3 
and		t2.sku_number = t1.sku_number
and		(T2.sku_type = 'T' or t2.sku_type = 'N') 
and		t4.sku_number = t1.sku_number
and     t4.Store_Number = t1.Store_Number
and		t1.day_date = @seldate
and		t2.Vendor_Number = 621   -- AWBC
group by t1.sku_number,t2.Class_Name
--Having	sum(t4.On_Hand) > 4
order by sum(current_dollars) desc
--

insert into ReportData.dbo.NonBook_Data_Key3
select	3 as Key_Number,
		Staging.dbo.tmp_key3.Rank,
		dssdata.dbo.card.sr_buyer,
		Staging.dbo.tmp_key3.sku_number,
		left(Staging.dbo.tmp_key3.Class_Name,20),
		Reference.dbo.item_master.title,
		Reference.dbo.item_master.author,
		dssdata.dbo.card.pub_code,
		Reference.dbo.item_master.sku_type,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2,
		 Reference.dbo.item_display_min t3
       where t1.sku_number = Staging.dbo.tmp_key3.sku_number
       and t3.sku_number = t1.sku_number
       and t1.Store_Number = t2.Store_Number
       and t3.store_number = t1.store_number
	   and t1.On_Hand < 1) as StockLT1,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.NonBookStore t2,
		 Reference.dbo.item_display_min t3
       where t1.sku_number = Staging.dbo.tmp_key3.sku_number
       and t3.sku_number = t1.sku_number
       and t1.Store_Number = t2.Store_Number
       and t3.store_number = t1.store_number
		 and t1.On_Hand >= t3.display_min) as StockGTM,
		NULL as StockLTM,
		NULL as PercAt,
        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
		 where sku_number = Staging.dbo.tmp_key3.sku_number),0)
		 as TotalOnHand,
        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
		isnull(Reference.dbo.ITBAL.OnPO,0) as WarehouseOnOrder,
		Staging.dbo.tmp_key3.WeekSalesDollars,
		Staging.dbo.tmp_key3.WeekSalesUnits,
		getdate() as Load_date
from	(Staging.dbo.tmp_key3  
         left join Reference.dbo.ITBAL  
         on Staging.dbo.tmp_key3.sku_number = Reference.dbo.ITBAL.sku_number)
		left join Reference.dbo.item_master 
		on Reference.dbo.item_master.sku_number = Staging.dbo.tmp_key3.sku_number
		left join dssdata.dbo.card
		on dssdata.dbo.card.sku_number = staging.dbo.tmp_key3.sku_number
where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
order by Rank
--
declare nbcur cursor for select distinct sku_number from ReportData.dbo.NonBook_Data_Key3
open nbcur
FETCH NEXT FROM nbcur into @tmpsku
while @@fetch_status = 0
begin
select @num_nb_stores = count(t1.store_number) 
						from	reference.dbo.invbal t1,
								reference.dbo.nonbookstore t2,
								reference.dbo.item_display_min t3
						where	t1.store_number = t2.store_number
						and		t1.sku_number = @tmpsku
						and		t3.sku_number = t1.sku_number
						and		t3.store_number = t1.store_number

update ReportData.dbo.NonBook_Data_Key3
set StockLTM = @num_NB_stores - StockGTM,
PercAt = (case 
           when @num_NB_stores = 0
             then 0
           when @num_NB_Stores <> 0
             then (StockGTM / @num_NB_stores) * 100
          end)
where sku_number = @tmpsku
--
fetch next from nbcur into @tmpsku
--
end
close nbcur
deallocate nbcur
--
--select	t1.Key_Number,
--			t1.Rank,
--			t1.Sku_Number,
--			t4.Title,
--			t3.Store_Number,
--			t3.on_hand,
--			t5.display_min 
--into		ReportData.dbo.OOS_Detail_Key3
--from		ReportData.dbo.NonBook_Data_Key3 t1,
--			Reference.dbo.NonBookStore t2,
--			Reference.dbo.INVBAL t3,
--			Reference.dbo.Item_Master t4,
--			Reference.dbo.item_display_min t5
--where		t3.Sku_Number = t1.sku_number
--and		t4.sku_number = t1.sku_number
--and		t3.store_number = t2.store_number
--and     t5.sku_number = t1.sku_number
--and		t5.store_number = t2.store_number
--and		t3.on_hand < t5.display_min 
--and		key_number = 3
--order by	t1.Rank

end





































GO
