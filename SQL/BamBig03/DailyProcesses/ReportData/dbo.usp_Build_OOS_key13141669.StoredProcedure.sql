USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_OOS_key13141669]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_Build_OOS_key13141669]
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
select @seldate = staging.dbo.fn_Last_Saturday(getdate())

drop table Staging.dbo.tmp_OOS_key13141669
drop table ReportData.dbo.OOS_key13141669

create table Staging.dbo.tmp_OOS_key13141669
		(Rank int NOT NULL identity(1,1),
		 Dept int,
		 sku_number bigint NOT NULL,
		 ISBN varchar(27),
		 Class_Name varchar(50) NULL,
		 WeekSalesDollars money NOT NULL,
		 WeekSalesUnits int NULL)
--
Create table ReportData.dbo.OOS_key13141669
		(Key_Number int NOT NULL,
		 Rank int not null,
		 Sr_Buyer varchar(30) NULL,
		 sku_number int not null,
		 ISBN varchar(27),
		 descr varchar(20) null,
		 title varchar(50) not null,
		 Author varchar(50) not null,
		 Pub_Code varchar(5),
		 sku_type char(2) not null,
		 StockLT1 int NULL,
		 TotalStr int null,
		 StockLTM int null,
		 PercAt float null,
		 TotalOH int null,
		 WarehouseOnHand int null,
		 WarehouseOnOrder int null,
		 WeekSalesDollars money null,
		 WeekSalesUnits int NULL,
		 Load_Date smalldatetime)
--
-- Build OOS Nonbook Data
--
insert into Staging.dbo.tmp_OOS_key13141669
select top 80 
		t2.Dept,
		t1.sku_number as sku_number,
		t2.isbn,
		t2.Class_Name as Class_Name, 
		sum(current_dollars) as WeekSalesDollars,
		sum(current_Units) as WeekSalesUnits
from	DssData.dbo.Weekly_Sales t1, 
		Reference.dbo.Item_Master t2,
		Reference.dbo.NonBookStore t3,
		Reference.dbo.INVBAL t4
where	t1.Store_Number = t3.Store_Number
and		t2.dept in (13,14,16,69) 
and		t2.sku_number = t1.sku_number
and		T2.sku_type in ('T', 'N') 
and		t4.sku_number = t1.sku_number
and     t4.Store_Number = t1.Store_Number
and		t1.day_date = @seldate
and		t2.Vendor_Number = 621   -- AWBC
group by t1.sku_number,t2.isbn,t2.Class_Name,t2.Dept
order by sum(current_dollars) desc
--

insert into ReportData.dbo.OOS_key13141669
select	staging.dbo.tmp_oos_key13141669.Dept, 
		Staging.dbo.tmp_oos_key13141669.Rank,
		left(dssdata.dbo.card.sr_buyer,50),
		Staging.dbo.tmp_oos_key13141669.sku_number,
		staging.dbo.tmp_oos_key13141669.isbn,
		left(Staging.dbo.tmp_oos_key13141669.Class_Name,20),
		Reference.dbo.item_master.title,
		Reference.dbo.item_master.author,
		dssdata.dbo.card.pub_code,
		left(Reference.dbo.item_master.sku_type,2),
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.item_display_min t3
       where t1.sku_number = Staging.dbo.tmp_oos_key13141669.sku_number
       and t3.sku_number = t1.sku_number
       and t3.store_number = t1.store_number
	   and t3.Display_Min > 0
	   and t1.On_Hand < 1) as StockLT1,
		(select count(t1.Store_number) 
		 from Reference.dbo.INVBAL t1,
		 Reference.dbo.item_display_min t3
       where t1.sku_number = Staging.dbo.tmp_oos_key13141669.sku_number
       and t3.sku_number = t1.sku_number
       and t3.store_number = t1.store_number
	   and t3.Display_Min > 0) as TotalStr,	   
		NULL as StockLTM,
		NULL as PercAt,
        isnull((select sum(On_Hand) from Reference.dbo.INVBAL
		 where sku_number = Staging.dbo.tmp_oos_key13141669.sku_number),0)
		 as TotalOnHand,
        isnull(Reference.dbo.ITBAL.OnHand,0) as WarehouseOnHand,
		isnull(Reference.dbo.ITBAL.OnPO,0) as WarehouseOnOrder,
		Staging.dbo.tmp_oos_key13141669.WeekSalesDollars,
		Staging.dbo.tmp_oos_key13141669.WeekSalesUnits,
		getdate() as Load_date
from	(Staging.dbo.tmp_OOS_key13141669 
         left join Reference.dbo.ITBAL  
         on Staging.dbo.tmp_oos_key13141669.sku_number = Reference.dbo.ITBAL.sku_number)
		left join Reference.dbo.item_master 
		on Reference.dbo.item_master.sku_number = staging.dbo.tmp_oos_key13141669.sku_number
		left join dssdata.dbo.card
		on dssdata.dbo.card.sku_number = staging.dbo.tmp_oos_key13141669.sku_number
where	Reference.dbo.ITBAL.WarehouseID = '1' or Reference.dbo.ITBAL.WarehouseID IS NULL
order by Rank
--
declare nbcur cursor for select distinct sku_number from ReportData.dbo.OOS_key13141669
open nbcur
FETCH NEXT FROM nbcur into @tmpsku
while @@fetch_status = 0
begin
select @num_nb_stores = count(t1.store_number) 
						from	reference.dbo.invbal t1,
								reference.dbo.item_display_min t3
						where	t1.sku_number = @tmpsku
						and		t3.sku_number = t1.sku_number
						and		t3.store_number = t1.store_number
						and		t3.Display_Min > 0

update ReportData.dbo.OOS_key13141669
set StockLTM = totalstr - StockLt1,
PercAt = (case 
           when @num_NB_stores = 0
             then 0
           when @num_NB_Stores <> 0
             then (cast(StockLT1 as float) / cast(totalstr as float)) * 100
          end)
where sku_number = @tmpsku
--
fetch next from nbcur into @tmpsku
--
end
close nbcur
deallocate nbcur
--

end










































GO
