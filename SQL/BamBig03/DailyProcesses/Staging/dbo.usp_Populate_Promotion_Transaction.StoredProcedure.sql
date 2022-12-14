USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Promotion_Transaction]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Populate_Promotion_Transaction]
as
--
declare @sd smalldatetime
--
select @sd = min(day_date) from dssdata.dbo.detail_transaction_period
--
delete from dssdata.dbo.Promotion_Transactions where day_date >= @sd
--
insert into dssdata.dbo.Promotion_Transactions
select day_date,
		store_number,
		transaction_nbr,
		transaction_code,
		sku_number,
		isbn,
		item_quantity,
		extended_price,
		extended_discount,
		reason_code,
		load_date from dssdata.dbo.detail_transaction_period
where reason_code is not null



GO
