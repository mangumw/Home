USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_detail_transaction_history]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_detail_transaction_history]
as
declare @rundate varchar(20)
declare @SD smalldatetime 
declare @ed smalldatetime 
--
select @rundate = left(getdate(),11) + ' 00:00:00'
select @ed = staging.dbo.fn_IntToDate(max(CSDATE)) from Staging.dbo.detail_transaction_period_Raw
select @sd = staging.dbo.fn_IntToDate(min(CSDATE)) from Staging.dbo.detail_transaction_period_Raw


--
delete from dssdata.dbo.detail_transaction_history
where day_date >= @sd and day_date <= @ed
--
insert into dssdata.dbo.Detail_Transaction_History
SELECT Distinct
       staging.dbo.fn_IntToDate(t1.CSDATE)
      ,t1.CSSTOR
      ,t1.CSREG#
      ,t1.CSTRN#
      ,t1.CSSEQ#
      ,t1.CSDTYP
      ,t1.CSTIME
      ,t2.Cashier_Number
      ,t1.CSSKU#
      ,t3.ISBN
      ,t1.CSQTY
      ,t1.CSRETL
      ,t1.CSCOST
      ,t1.CSEXPR
      ,t1.CSEXDS
      ,t1.CSPOVR
      ,t1.CSUPC#
      ,t1.CSRGPR
      ,t1.CSRSNC
	  ,t2.customer_number
      ,getdate()
	  ,t1.cepdpt

  FROM Staging.dbo.Detail_Transaction_Period_Raw t1,
	   dssdata.dbo.header_transaction t2,
		reference.dbo.item_master t3
where	t2.day_date = staging.dbo.fn_IntToDate(t1.CSDATE)
and		t1.csdtyp IN ('01', '02', '04', '11', '14', '22','31','53','85', '86','ES','ED','VS')
and     t2.store_number <>'54'
and		t2.store_number = t1.CSSTOR
and		t2.register_number = t1.CSREG#
and		t2.transaction_number = t1.CSTRN#
and		t3.sku_number = t1.CSSKU#

GO
