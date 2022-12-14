USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_Book]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE Procedure [dbo].[usp_Build_OOS_Book]
as
Begin

declare @num_NB_stores float
declare @num_drink_stores float
declare @seldate smalldatetime
declare @fiscal_week int
declare @fiscal_year int
declare @tmpsku int
--
select @num_NB_stores = count(Store_Number) from Reference.dbo.NonBookStore
select @num_drink_stores = count(Store_Number) from Reference.dbo.Drink_Store
--
select @seldate = staging.dbo.fn_Last_Saturday(getdate())
--
drop table ReportData.dbo.NonBook_Data_key148
--
create table #tmp_key148
		(Rank int NOT NULL identity(1,1),
		 Dept int,
		 sku_number bigint NOT NULL,
		 ISBN varchar(20),
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.NonBook_Data_key148
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
		 SR_Buyer varchar(50),
		 Buyer varchar(50),
		 IDate smalldatetime,
		 StockLT1 float NULL,
		 StockGTM float null,
		 StockLTM float null,
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
insert into #tmp_key148
select top 1500
		t2.Dept,
		t1.sku_number as sku_number,
		t2.ISBN,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.active_stores t3
where	t1.Store_Number = t3.Store_Number
and		t2.dept in (1,4,8) 
and		t2.sku_number = t1.sku_number
and		(T2.sku_type in ('T','N','B')) 
and		t1.day_date = @seldate
group by t1.sku_number,t2.Class_Name,t2.ISBN,t2.Dept
order by sum(current_dollars) desc
--
insert into ReportData.dbo.NonBook_Data_key148
select	t1.Dept,
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
		t5.idate,
		(select count(t14.Store_number) 
		 from Reference.dbo.INVBAL t14,
		 Reference.dbo.NonBookStore t21,
		 Reference.dbo.item_display_min t31
       where t14.sku_number = t1.sku_number
       and t31.sku_number = t14.sku_number
       and t14.Store_Number = t21.Store_Number
       and t31.store_number = t14.store_number
	   and t14.On_Hand < 1) as StockLT1,
		(select count(t9.Store_number) 
		 from Reference.dbo.INVBAL t9,
		 Reference.dbo.NonBookStore t10,
		 Reference.dbo.item_display_min t11
       where t9.sku_number = t1.sku_number
       and t11.sku_number = t9.sku_number
       and t9.Store_Number = t10.Store_Number
       and t11.store_number = t9.store_number
		 and t9.On_Hand >= t11.display_min) as StockGTM,
		NULL as StockLTM,
		(select count(t7.Store_number) 
		 from Reference.dbo.INVBAL t7
       where t7.sku_number = t1.sku_number
		 and t7.On_Hand > 0) as totalStocked,
		NULL as InTransit,
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
from	#tmp_key148 t1,  
		Reference.dbo.item_master t2,
		Reference.dbo.extended_pidstats t3,
		dssdata.dbo.CARD t5
where	t2.sku_number = t1.sku_number
and		t3.pid = t2.ISBN
and		t5.sku_number = t1.sku_number
order by Rank
--
--declare nbcur cursor for select distinct sku_number from ReportData.dbo.NonBook_Data_key148
--open nbcur
--FETCH NEXT FROM nbcur into @tmpsku
--while @@fetch_status = 0
--begin
--select @num_nb_stores = count(t1.store_number) 
--						from	reference.dbo.invbal t1
--						where	t1.sku_number = @tmpsku

update ReportData.dbo.NonBook_Data_key148
set PercAt = (case 
           when stocklt1 > 0
             then stocklt1 / (Totalstocked - stocklt1) * 100
		   else 0
          end)
--where sku_number = @tmpsku
--
--fetch next from nbcur into @tmpsku
----
--end
--close nbcur
--deallocate nbcur
End
































GO
