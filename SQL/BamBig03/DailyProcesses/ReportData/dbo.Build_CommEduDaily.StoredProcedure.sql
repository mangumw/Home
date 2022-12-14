USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_CommEduDaily]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Build_CommEduDaily]
as

declare @begin_date varchar(8)
declare @end_date varchar (8)
declare @ly_fiscal_year int 
select   @ly_fiscal_year = 
fiscal_year-1 from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales)

select @begin_date =  day_date from reference.dbo.calendar_dim where fiscal_year = @ly_fiscal_year and day_of_fiscal_year = 1
select @end_date = getdate()


If exists (select name from staging.dbo.sysobjects where name = 'tmp_CommCards')
	Drop Table staging.dbo.tmp_CommCards
--
select	mcustnum,
		MFNAME,
		MLNAME,
		MCompany,
		EMail,
		MSPECIAL
into	staging.dbo.tmp_CommCards
from	dssdata.dbo.gclu
where	(MSpecial in ('COMM','CORP','TEACHER'))
Or		PClientType = 'INS'
--
truncate table reportdata.dbo.CommEduDaily

insert into reportdata.dbo.CommEduDaily
select	t1.day_date as Date,
        t1.store_number as Store,
        isnull(sum(t3.Extended_price),0) as Cust_Sales
from	dssdata.dbo.header_transaction t1,
		staging.dbo.tmp_CommCards t2,
		dssdata.dbo.detail_transaction_History t3
Where	t1.customer_number = t2.MCustNum
and		t1.day_date >= @begin_date 
and		t3.day_date = t1.day_date
and		t3.transaction_nbr = t1.transaction_Number
and		t3.register_nbr = t1.register_Number
and		t3.store_number = t1.store_number
group by t1.day_date,t1.store_number



GO
