USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_Calendars]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE Procedure [dbo].[usp_Build_OOS_Calendars]
as
Begin
--
declare @seldate smalldatetime
declare @fiscal_week int
declare @fiscal_year int
declare @tmpsku int
--
select @seldate = staging.dbo.fn_Last_Saturday(getdate())
--
truncate table ReportData.dbo.NonBook_Data_Calendars
truncate table staging.dbo.tmp_calendars
--
--create table Staging.dbo.tmp_Calendars
--		(Rank int NOT NULL identity(1,1),
--		 sku_number int NOT NULL,
--		 ISBN varchar(20),
--		 WeekSalesDollars money NOT NULL,
--		 WeekSalesUnits int NULL)
----
--Create table ReportData.dbo.NonBook_Data_Calendars
--		(Key_Number int NOT NULL,
--		 Rank int not null,
--		 sku_number int not null,
--		 ISBN varchar(20),
--		 SDept_Name varchar(50) NOT NULL,
--		 item_name varchar(50) not null,
--		 Author varchar(50) not null,
--		 sku_type char not null,
--		 Buyer_Init varchar(3),
--		 StockLT1 int NULL,
--		 StockLT2 int null,
--		 StockLT3 int null,
--		 TotalStocked int NULL,
--		 InTransit int NULL,
--		 PercAt float null,
--		 TotalOH int null,
--		 WarehouseOnHand int null,
--		 WarehouseOnOrder int null,
--		 WeekSalesDollars money null,
--		 WeekSalesUnits int NULL,
--		 Load_Date smalldatetime)
--
-- Build Calendar Data
--
insert into Staging.dbo.tmp_Calendars
select 	t1.sku_number as sku_number,
		t2.ISBN,
		Week1Dollars as WeekSalesDollars,
		Week1Units as WeekSalesUnits
from	DssData.dbo.CARD t1 join  
		Reference.dbo.Calendar_OOS_Ref t2 on t1.sku_number = t2.sku_number
order by t1.Week1Dollars desc
--
insert into ReportData.dbo.NonBook_Data_Calendars
select	99 as Key_Number,
		t1.Rank,
		t1.sku_number,
		t1.ISBN,
		t2.SDept_Name,
		t2.title,
		t2.author,
		t2.sku_type,
		t6.Sr_Buyer,
		(select count(reference.dbo.invbal.store_number)
		 from reference.dbo.invbal
		 where reference.dbo.invbal.sku_number = t1.sku_number
		 and On_Hand < 1) as StockLT1,
		(select count(reference.dbo.invbal.store_number)
		 from reference.dbo.invbal
		 where reference.dbo.invbal.sku_number = t1.sku_number
		 and On_Hand < 2) as StockLT2,
		(select count(reference.dbo.invbal.store_number)
		 from reference.dbo.invbal
		 where reference.dbo.invbal.sku_number = t1.sku_number
		 and On_Hand < 3) as StockLT3,
		(select top 1 Stocked_Stores as TotalStocked
		 from reference.dbo.Calendar_OOS_Ref
		 where ISBN = t1.ISBN )
		 as Total_Stocked,
		t5.InTransit,
		NULL as PercAt,
        t5.BAM_OnHand as TotalOnHand,
        t5.Warehouse_OnHand,
		t5.Qty_OnOrder as WarehouseOnOrder,
		t1.WeekSalesDollars,
		t1.WeekSalesUnits,
		getdate() as Load_date
from	Staging.dbo.tmp_Calendars t1,  
		Reference.dbo.item_master t2,
		dssdata.dbo.CARD t5,
		reference.dbo.buyer_srbuyer_xref t6
where	t2.sku_number = t1.sku_number
and		t5.sku_number = t1.sku_number
and		t6.buyer_number = t2.buyer_number
order by Rank
--
update ReportData.dbo.NonBook_Data_Calendars
set PercAt = 100.00 - ((cast(TotalStocked as float)-cast(StockLT1 as float))/cast(TotalStocked as float)) * 100
--
--truncate table ReportData.dbo.OOS_Detail
--insert into ReportData.dbo.OOS_Detail
--select	t1.Key_Number,
--			1 as num,
--			t1.Rank,
--			t1.Sku_Number,
--			t4.Title,
--			t3.Store_Number 
--from		ReportData.dbo.NonBook_Data_Calendars t1,
--			Reference.dbo.INVBAL t3,
--			Reference.dbo.Item_Master t4
--where		t3.Sku_Number = t1.sku_number
--and		t4.Sku_Number = t1.Sku_Number
--and		t3.on_hand < 1
--and		key_number = 99
--order by	t1.Rank



end



























GO
