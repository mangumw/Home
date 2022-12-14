USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_voucher_sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_build_voucher_sales]
as
declare @fr smalldatetime
select @fr = min(day_date) from dssdata.dbo.detail_transaction_period
delete from dssdata.dbo.voucher_sales where day_date >= @fr

insert into DSSDATA.dbo.voucher_sales
select	t1.day_date,
		t1.store_number,
		t1.register_nbr,
		t1.transaction_nbr,
		t1.sequence_nbr,
		t1.transaction_code,
		t1.transaction_time,
		t1.sku_number,
		t1.ISBN,
		t1.item_quantity,
		t1.unit_retail,
		t1.unit_cost,
		t1.extended_price,
		t1.Extended_discount,
		t1.price_override,
		t1.unit_regular_price,
		NULL as Department,
		t1.reason_code,
		getdate() as load_date
from	dssdata.dbo.detail_transaction_period t1
where	t1.transaction_code = 'VS'	
order by day_date, store_number




GO
