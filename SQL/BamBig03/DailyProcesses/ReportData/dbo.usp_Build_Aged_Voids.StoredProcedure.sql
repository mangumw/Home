USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Aged_Voids]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Aged_Voids]
as

--Commented out 3/23/2017.  Taking around 20 minutes to run each day. New query takes less than 2 minutes with same results.
--select	t3.Store_Number,
--		t1.sku_number,
--		t1.StatusDate,
--		t1.TypeChangeDate,
--		t2.sku_Type,
--		t2.POS_Price,
--		sum(t3.On_Hand) as OnHand,
--		datediff(dd,staging.dbo.fn_IntToDate(t1.typechangedate),getdate()) as DaysPastDue
--into	#voiddates
--from	reference.dbo.invmste t1 join reference.dbo.invmst t2
--on		t1.sku_number = t2.sku_number
--left join	reference.dbo.invbal t3
--on		t3.sku_number = t2.sku_number
--group by t3.store_number,t1.sku_number,t1.statusdate,t1.TypeChangeDate,t2.sku_type,t2.POS_Price
--having  t2.sku_type = 'V' and t1.StatusDate = t1.TypeChangeDate
--and		sum(t3.On_Hand) > 0
--Order by t1.sku_number

--Get void SKUs in book departments where the status data and change date are the same
select t1.sku_number,
		t1.StatusDate,
		t1.TypeChangeDate,
		t2.sku_Type,
		t2.POS_Price
into    #Skus
from	reference.dbo.invmste t1 join reference.dbo.invmst t2
on		t1.sku_number = t2.sku_number
where   t2.sku_type = 'V' and t2.dept in (1,4,8) and  t1.Statusdate = t1.TypeChangeDate

--Get INVBAL records for those SKUs where On Hands are greater than zero
select sku_number,
	   Store_Number,
	   On_Hand
into #balance
from reference.dbo.invbal 
where On_Hand > 0 and sku_number in (select sku_number from #Skus)

--Combine SKU and Balance files to get on-hands and date difference
select	t1.Store_Number,
		t2.sku_number,
		t2.StatusDate,
		t2.TypeChangeDate,
		t2.sku_Type,
		t2.POS_Price,
		t1.On_Hand as OnHand,
		datediff(dd,staging.dbo.fn_IntToDate(t2.typechangedate),getdate()) as DaysPastDue
into    #voiddates
from	#balance t1
left join #skus t2 on t1.sku_number = t2.sku_number 
Order by t1.sku_number

drop table #balance
drop table #skus

--update Aged Voids table
truncate table reportdata.dbo.Aged_Voids
insert into	reportdata.dbo.Aged_Voids
select	t1.store_number,
		t2.dept,
		t2.dept_name,
		t2.sdept,
		t2.sdept_name,
		t2.class,
		t2.class_name,
		t1.sku_number,
		t2.Title,
		case 
			when t1.DaysPastDue < 30 then t1.POS_Price * t1.OnHand
			else 0
		end as LessThan30D,
		case 
			when t1.DaysPastDue >= 30  and t1.DaysPastDue < 60 then t1.POS_Price * t1.OnHand
			else 0
		end as ThirtyTo60D,
		case 
			when t1.DaysPastDue >= 60  and t1.DaysPastDue < 90 then t1.POS_Price * t1.OnHand
			else 0
		end as SixtyTo90D,
		case 
			when t1.DaysPastDue >= 90 then t1.POS_Price * t1.OnHand
			else 0
		end as Over90D,
		case 
			when t1.DaysPastDue < 30 then t1.OnHand
			else 0
		end as LessThan30U,
		case 
			when t1.DaysPastDue >= 30  and t1.DaysPastDue < 60 then t1.OnHand
			else 0
		end as ThirtyTo60U,
		case 
			when t1.DaysPastDue >= 60  and t1.DaysPastDue < 90 then t1.OnHand
			else 0
		end as SixtyTo90U,
		case 
			when t1.DaysPastDue >= 90 then t1.OnHand
			else 0
		end as Over90U
from	#VoidDates t1,
		reference.dbo.item_master t2
where	t2.sku_number = t1.sku_number
--and		t2.Dept in (1,4,8)
and		t1.DaysPastDue >= 30
order by t1.store_number,t1.sku_number

drop table #voiddates



GO
