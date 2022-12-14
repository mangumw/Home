USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Other_Trans_History]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Other_Trans_History]
as
--
declare @sd smalldatetime
declare @ed smalldatetime
select @sd = staging.dbo.fn_IntToDate(min(CSDATE)) from Staging.dbo.Detail_Transaction_Period_Raw
select @ed = staging.dbo.fn_IntToDate(max(CSDATE)) from Staging.dbo.Detail_Transaction_Period_Raw
--
delete from dssdata.dbo.other_transaction_history
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
    t4.CEPDPT,
	t1.CSDOSP
from Staging.dbo.Detail_Transaction_Period_Raw t1 
left join Reference.dbo.item_master t2 on
t2.sku_number = cast(t1.[CSSKU#] as bigint)
join dssdata.dbo.header_transaction t3
on t3.day_date = dbo.fn_IntToDate(t1.CSDATE)
and t3.store_number = t1.csstor
and t3.register_number = t1.csreg#
and t3.transaction_number = t1.cstrn#
left join staging.dbo.wrk_cshdete t4
on t4.cestor = t1.csstor
and t4.cedate = t1.csdate
and t4.cereg# = t1.csreg#
and t4.cetrn# = t1.cstrn#
and t4.ceseq# = t1.csseq#
where csdtyp NOT IN ('01', '02', '04', '11', '14', '22', '53', '85', '86','ES','VS')
GO
