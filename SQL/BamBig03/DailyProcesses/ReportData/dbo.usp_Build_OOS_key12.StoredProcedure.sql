USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_key12]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--
CREATE Procedure [dbo].[usp_Build_OOS_key12]
as
Begin
--
declare @num_NB_stores float
declare @num_drink_stores float
declare @seldate smalldatetime
declare @fiscal_week int
declare @fiscal_year int
declare @tmpsku int
declare @totstr float
declare @lt1 float
declare @percat float
declare @sku_number int
declare @rank int
--
select @num_NB_stores = count(Store_Number) from Reference.dbo.NonBookStore
select @num_drink_stores = count(Store_Number) from Reference.dbo.Drink_Store

select @seldate = staging.dbo.fn_Last_Saturday(getdate())
--
drop table ReportData.dbo.NonBook_Data_key12
--
create table #tmp_key12
		(Rank int NOT NULL identity(1,1),
		 sku_number bigint NOT NULL,
		 ISBN varchar(20),
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.NonBook_Data_key12
		(Key_Number int NOT NULL,
		 Rank int not null,
		 SR_Buyer varchar(30) NULL,
		 sku_number int not null,
		 ISBN varchar(20),
		 SDept_Name varchar(50) NOT NULL,
		 descr varchar(30) null,
		 item_name varchar(50) not null,
		 Author varchar(50) not null,
		 pub_code varchar(5),
		 sku_type char not null,
		 StockLT1 int NULL,
		 StockGTM int null,
		 StockLTM int null,
		 TotalStocked int NULL,
		 InTransit int NULL,
		 PercAt float null,
		 TotalOH int null,
		 WarehouseOnHand int null,
		 WarehouseOnOrder int null,
		 WeekSalesDollars money null,
		 WeekSalesUnits int NULL,
		 Load_Date smalldatetime)
--
-- Build Key 12 Data
--
insert into #tmp_key12
select 	top 200 
		t1.sku_number as sku_number,
		t2.ISBN,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.active_stores t3
where	t1.Store_Number = t3.Store_Number
and		t2.dept = 12
and		t2.sku_number = t1.sku_number
and		(T2.sku_type in ('T','N','B')) 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name,t2.ISBN
order by sum(current_dollars) desc
--
insert into ReportData.dbo.NonBook_Data_key12
select	12 as Key_Number,
		t1.Rank,
		t5.SR_Buyer,
		t1.sku_number,
		t1.ISBN,
		t2.SDept_Name,
		left(t1.Class_Name,20) as Class,
		t2.title,
		t2.author,
		t5.pub_code,
		t2.sku_type,
		(select count(t11.store_number)
		 from reference.dbo.invbal t11,
			  reference.dbo.item_display_min t12
		 where t11.sku_number = t1.sku_number
         and t12.sku_number = t1.sku_number      
		 and t12.store_number = t11.store_number
		 and t11.On_Hand = 0) as StockLT1,
		NULL as StockGTM,
		NULL as StockLTM,
		(select count(t4.store_number)
		 from reference.dbo.invbal t4,
              reference.dbo.item_display_min t5
		 where t4.sku_number = t1.sku_number
         and t5.store_number = t4.store_number
         and t5.sku_number = t4.sku_number)
		 as Total_Stocked,
		t5.InTransit,
		NULL as PercAt,
        t5.BAM_OnHand as TotalOnHand,
        t5.Warehouse_OnHand,
		t5.Qty_OnOrder as WarehouseOnOrder,
		t1.WeekSalesDollars,
		t1.WeekSalesUnits,
		getdate() as Load_date
from	#tmp_key12 t1,  
		Reference.dbo.item_master t2,
		dssdata.dbo.CARD t5
where	t2.sku_number = t1.sku_number
and		t5.sku_number = t1.sku_number

order by Rank
--
declare cur cursor for select rank,sku_number,totalstocked,stocklt1
from reportdata.dbo.nonbook_data_key12
order by stocklt1 desc
--
open cur
--
fetch next from cur into @rank,@sku_number,@totstr,@lt1
--
while @@fetch_status = 0
begin
if @lt1 = 0
  set @percat = 0
else
  set @percat = (@lt1 / @totstr) * 100

update reportdata.dbo.nonbook_data_key12
set PercAt = @percat
where Rank = @rank and Sku_Number = @sku_number

fetch next from cur into @rank,@sku_number,@totstr,@lt1
end
close cur
deallocate cur

end

































GO
