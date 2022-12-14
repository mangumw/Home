USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_Key58]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--
CREATE Procedure [dbo].[usp_Build_OOS_Key58]
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
drop table ReportData.dbo.NonBook_Data_key58
--
create table #tmp_key58
		(Rank int NOT NULL identity(1,1),
		 sku_number bigint NOT NULL,
		 ISBN varchar(20),
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.NonBook_Data_key58
		(Key_Number int NOT NULL,
		 Rank int not null,
		 sku_number int not null,
		 ISBN varchar(20),
		 SDept_Name varchar(50) NOT NULL,
		 descr varchar(20) null,
		 item_name varchar(50) not null,
		 Author varchar(50) not null,
		 pub_code varchar(5),
		 sku_type char not null,
		 sr_Buyer varchar(30),
		 buyer varchar(30),
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
select  t1.sku_number,
		t1.store_number,
		t1.On_Hand,
		t2.Display_Min
into	#tmp_Min
from	reference.dbo.invbal t1,
		reference.dbo.item_display_min t2
where	t2.sku_number = t1.sku_number
and		t2.store_number = t1.store_number
		
--
-- Build Calendar Data
--
insert into #tmp_key58
select 	t1.sku_number as sku_number,
		t2.ISBN,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.active_stores t3
where	t1.Store_Number = t3.Store_Number
and		t2.dept = 58
and		t2.sku_number = t1.sku_number
and		(T2.sku_type in ('T','N','B')) 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name,t2.ISBN
order by sum(current_dollars) desc
--
insert into ReportData.dbo.NonBook_Data_key58
select	58 as Key_Number,
		t1.Rank,
		t1.sku_number,
		t1.ISBN,
		t2.SDept_Name,
		left(t1.Class_Name,20) as Class,
		t2.title,
		t2.author,
		t5.pub_code,
		t2.sku_type,
		t5.sr_Buyer,
		t5.buyer,
		(select count(reference.dbo.invbal.store_number)
		 from reference.dbo.invbal,
		      reference.dbo.item_display_min
		 where reference.dbo.invbal.sku_number = t1.sku_number
         and   reference.dbo.item_display_min.sku_number = t1.sku_number
         and   reference.dbo.item_display_min.store_number = reference.dbo.invbal.store_number
		 and   reference.dbo.invbal.On_Hand < reference.dbo.item_display_min.display_min) as StockLT1,
		NULL as StockGTM,
		NULL as StockLTM,
		(select count(reference.dbo.invbal.store_number)
		 from reference.dbo.invbal,
			  reference.dbo.active_stores
		 where sku_number = t1.sku_number 
         and reference.dbo.invbal.store_number = reference.dbo.active_stores.store_number)
		 as Total_Stocked,
		t5.InTransit,
		NULL as PercAt,
        t5.BAM_OnHand as TotalOnHand,
        t5.Warehouse_OnHand,
		t5.Qty_OnOrder as WarehouseOnOrder,
		t1.WeekSalesDollars,
		t1.WeekSalesUnits,
		getdate() as Load_date
from	#tmp_key58 t1,  
		Reference.dbo.item_master t2,
		dssdata.dbo.CARD t5
where	t2.sku_number = t1.sku_number
and		t5.sku_number = t1.sku_number
order by Rank
--
update ReportData.dbo.NonBook_Data_key58
set PercAt = 100.00 - ((cast(TotalStocked as float)-cast(StockLT1 as float))/cast(TotalStocked as float)) * 100
--
end

































GO
