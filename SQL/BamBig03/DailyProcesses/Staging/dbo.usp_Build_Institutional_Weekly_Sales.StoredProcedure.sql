USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Institutional_Weekly_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Institutional_Weekly_Sales]
as
--
-- This proc populates the Institutional_Weekly_Sales table with the 
-- transactions from customers marked as Institutional as well as
-- transactions from Educator Card customers
--
declare @SD smalldatetime
declare @ED smalldatetime
--
select @ED = staging.dbo.fn_last_saturday(getdate())
select @SD = dateadd(dd,1,staging.dbo.fn_last_saturday(dateadd(dd,-6,getdate())))
--
-- First, create the work table with institutional customer transactions
--
truncate table staging.dbo.wrk_Institutional_Sales
--
insert into staging.dbo.wrk_Institutional_Sales
select	t1.day_date,
		t1.store_number,
		t1.Transaction_Type,
		t1.register_Number,
		t1.Roll_Over,
		t1.Transaction_Number,
		t2.Sequence_Nbr,
		t2.Transaction_Code,
		t2.sku_Number,
		t2.Unit_Retail,
		t2.Unit_Cost,
		t2.Item_Quantity,
		t2.Extended_Price,
		t2.Extended_Discount,
		t2.Unit_Regular_Price,
		t1.Customer_Number
from	dssdata.dbo.header_Transaction t1,
		dssdata.dbo.detail_Transaction_Period t2,
		dssdata.dbo.GCLU t3
where	t1.day_date >= @SD and t1.day_date <= @ED
and		t1.Customer_Number = t3.MCustNum
and		t3.mspecial in ('Corp','Comm')
and		t2.store_Number = t1.Store_Number
and		t2.day_date = t1.day_date
and		t2.register_nbr = t1.register_number
and		t2.transaction_nbr = t1.Transaction_Number

--
delete from DssData.dbo.Institutional_Weekly_Sales
where day_date = @ED
--
--
insert into Dssdata.dbo.Institutional_Weekly_Sales
select	@ED as day_date,
		t1.date as Transaction_Date,
		t1.Store_Number,
		t2.Store_Name,
		'I' as Sale_Type,
		t1.Sku_Number,
		t3.ISBN,
		t3.PubCode,
		sum(t1.Qty_Sold) as Current_Units,
		sum(t1.Extended_Price) as Current_Dollars
from	staging.dbo.wrk_Institutional_Sales t1 left join
		reference.dbo.active_stores t2 on t2.store_number = t1.store_number
		inner join reference.dbo.item_master t3
		on t3.sku_number = t1.sku_number
where	t1.date >= @SD and t1.date <= @ED
group by t1.store_number,t2.store_name,t1.date,
		t1.sku_number,t3.isbn,t3.author,t3.pubcode
order by t1.store_number
--
-- Insert Educator Card Sales
--
insert into Dssdata.dbo.Institutional_Weekly_Sales
select	@ED as day_date,
		t1.day_date as Transaction_Date,
		t1.Store_Number,
		t3.Store_Name,
		'E' as Sale_Type,
		t2.Sku_Number,
		t2.ISBN,
		t5.PubCode,
		sum(t2.Item_Quantity) as Current_Units,
		sum(t2.Extended_Price) as Current_Dollars
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_history t2,
		reference.dbo.active_stores t3,
		Dssdata.dbo.GCLU t4,
		reference.dbo.item_master t5
where	t1.customer_number = t4.mcustnum
and		t4.mspecial = 'Teacher'
and		t1.day_date >= @SD and t1.day_date <= @ED
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.register_nbr = t1.register_number
and		t2.transaction_nbr = t1.transaction_number
and		t3.store_number = t1.store_number
and		t5.sku_number = t2.sku_number
group by t1.day_date,t1.store_number,t3.store_name,t2.sku_number,t2.isbn,t5.pubcode
order by t1.store_number


		








GO
