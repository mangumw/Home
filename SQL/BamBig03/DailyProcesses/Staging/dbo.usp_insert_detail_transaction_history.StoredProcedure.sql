USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_insert_detail_transaction_history]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_insert_detail_transaction_history]
as
declare @rundate varchar(20)
declare @SD smalldatetime
declare @ed smalldatetime
--
select @rundate = left(getdate(),11) + ' 00:00:00'
select @ed = max(day_date) from dssdata.dbo.detail_transaction_period
select @sd = min(day_date) from dssdata.dbo.detail_transaction_period

--
delete from dssdata.dbo.detail_transaction_history
where day_date >= @sd and day_date <= @ed
--
insert into dssdata.dbo.Detail_Transaction_History
SELECT t1.Day_Date
      ,t1.Store_Number
      ,t1.Register_Nbr
      ,t1.Transaction_Nbr
      ,t1.Sequence_Nbr
      ,t1.Transaction_Code
      ,t1.Transaction_Time
      ,t2.Cashier_Number
      ,t1.Sku_Number
      ,t1.ISBN
      ,t1.Item_Quantity
      ,t1.Unit_Retail
      ,t1.Unit_Cost
      ,t1.Extended_Price
      ,t1.Extended_Discount
      ,t1.Price_Override
      ,t1.UPC_Number
      ,t1.Unit_Regular_Price
      ,t1.Reason_Code
	  ,t2.customer_number
      ,t1.Load_Date
      ,t1.Dept
  FROM DssData.dbo.Detail_Transaction_Period t1,
	   dssdata.dbo.header_transaction t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.register_number = t1.register_nbr
and		t2.transaction_number = t1.transaction_nbr
--
delete from dssdata.dbo.Other_transaction_history
where day_date >= @sd and day_date <= @ed
--
insert into dssdata.dbo.other_transaction_history
select 
	dbo.fn_IntToDate(CSDATE) as day_date,
	t1.CSSTOR as Store_Number,
	t1.[CSREG#] as register_nbr,
	t1.[CSTRN#] as transaction_nbr,
	t1.[CSSEQ#] as sequence_number,
	t1.[CSDTYP] as transaction_code,
	t1.CSTIME as transaction_time,
	t3.Cashier_Number as Cashier_nbr,
	case t1.[CSSKU#] 
       when 0 then NULL
       else t1.[cssku#]
    end as sku_number,
	t2.isbn as ISBN,
	t1.CSQTY as item_quantity,
	t1.CSRETL as unit_retail,
	t1.CSCOST as unit_cost,
	t1.CSEXPR as extended_price,
	t1.CSEXDS as extended_Discount,
	case t1.CSPOVR
	  when 'P' then 'Y'
	  else 'N'
	end as price_override,
	t1.CSUPC# as UPC_Number,
	t1.CSRGPR as unit_regular_price,
	t1.CSRSNC as Reason_Code,
	t3.customer_number,
	getdate() as load_date,
	case t1.csdtyp
	  when '44' then 44
	  when '45' then 45
	  else t1.cepdpt
    end as Dept,
    t1.csdosp
from Staging.dbo.Detail_Transaction_Period_Raw t1 
left join Reference.dbo.item_master t2 on
t2.sku_number = cast(t1.[CSSKU#] as bigint)
join dssdata.dbo.header_transaction t3
on t3.day_date = dbo.fn_IntToDate(t1.CSDATE)
and t3.store_number = t1.csstor
and t3.register_number = t1.csreg#
and t3.transaction_number = t1.cstrn#
where csdtyp NOT IN ('01', '02', '03', '04', '11', '14', '22', '31', '53', '85', '86','ES','ED','VS')




















GO
