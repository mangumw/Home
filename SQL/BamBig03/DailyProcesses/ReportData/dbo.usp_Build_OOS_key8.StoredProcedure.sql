USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_key8]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--
CREATE Procedure [dbo].[usp_Build_OOS_key8]
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
drop table ReportData.dbo.NonBook_Data_key8
--
create table #tmp_key8
		(Rank int NOT NULL identity(1,1),
		 sku_number bigint NOT NULL,
		 ISBN varchar(20),
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.NonBook_Data_key8
		(Key_Number int NOT NULL,
		 Rank int not null,
		 sku_number int not null,
		 ISBN varchar(20),
		 SDept_Name varchar(50) NOT NULL,
		 descr varchar(20) null,
		 item_name varchar(50) not null,
		 Author varchar(50) not null,
		 Pub_Code varchar(5),
		 sku_type char not null,
		 Sr_Buyer_Name varchar(50),
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
-- Build Key 4 Data
--
insert into #tmp_key8
select top 200 
		t1.sku_number as sku_number,
		t2.ISBN,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.active_stores t3,
		Reference.dbo.extended_pidstats t4
where	t1.Store_Number = t3.Store_Number
and		t2.dept = 8 
and		t2.sku_number = t1.sku_number
and		t4.pid = t2.isbn
and		t4.numstocked > 0
and		t4.numstockedout > 0
and		(T2.sku_type in ('T','N','B')) 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name,t2.ISBN
order by sum(current_dollars) desc
--
insert into ReportData.dbo.NonBook_Data_key8
select	8 as Key_Number,
		t1.Rank,
		t1.sku_number,
		t1.ISBN,
		t2.SDept_Name,
		left(t1.Class_Name,20) as Class,
		t2.title,
		t2.author,
		t5.pub_code,
		t2.sku_type,
		t5.Sr_Buyer,
		t3.numstockedout as StockLT1,
		(t3.numstocked - t3.numneeded) as StockGTM,
		t3.numneeded as StockLTM,
		t3.numstocked as TotalStocked,
		t5.InTransit,
		case
			when t3.numstockedout < 1 then 0
			else (cast(t3.numstockedout as float) / cast(t3.numstocked as float))*100
		end as PercAt,
        t5.BAM_OnHand as TotalOnHand,
        t5.Warehouse_OnHand,
		t5.Qty_OnOrder as WarehouseOnOrder,
		t1.WeekSalesDollars,
		t1.WeekSalesUnits,
		getdate() as Load_date
from	#tmp_key8 t1,  
		Reference.dbo.item_master t2,
		Reference.dbo.extended_pidstats t3,
		dssdata.dbo.CARD t5
where	t2.sku_number = t1.sku_number
and		t3.pid = t2.ISBN
and		t5.sku_number = t1.sku_number
order by Rank
--
end































GO
