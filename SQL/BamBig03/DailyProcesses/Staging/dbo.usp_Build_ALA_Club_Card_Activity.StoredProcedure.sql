USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_ALA_Club_Card_Activity]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[usp_Build_ALA_Club_Card_Activity]
as
declare @Start_Date_int int
declare @Start_Date smalldatetime
--
select @Start_Date_int = min(csdate) from staging.dbo.detail_transaction_period_raw
select @Start_Date = staging.dbo.fn_IntToDate(@Start_Date_Int)
--
delete from dssdata.dbo.ALA_Club_Card_Activity where day_date >= @Start_Date
--
insert into dssdata.dbo.Club_Card_Activity
SELECT	staging.dbo.fn_IntToDate(t1.csdate)
		,t1.CSSTOR
		,t1.CSREG#
		,t1.CSTRN#
		,t1.CSSEQ#
		,t1.CSDTYP
		,t1.CSTIME
		,t2.Customer_Number
		,t3.MFNAME
		,t3.MLName
		,t3.MCompany
		,t3.MCreateDate
		,t3.ExpDate1
		,t3.ExpDate2
		,t3.ExpDate3
		,t3.XLastModDate
		,t3.MSpecial
		,t3.PClientType
		,t1.CSRETL
		,GetDate()
FROM	staging.dbo.Detail_Transaction_Period_Raw t1,
		dssdata.dbo.header_transaction t2,
		dssdata.dbo.gclu t3
where	t2.day_date = staging.dbo.fn_IntToDate(t1.CSDATE)
and		t2.store_number = t1.CSSTOR
and		t2.transaction_number = t1.CSTRN#
and		t2.register_number = t1.CSREG#
and		t1.CSDTYP = 'ALA'
and		t3.MCustNum = t2.Customer_Number

GO
