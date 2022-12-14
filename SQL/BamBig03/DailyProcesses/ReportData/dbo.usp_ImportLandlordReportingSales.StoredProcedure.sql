USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportLandlordReportingSales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 04/27/2022
-- Description:	Landlord Reporting
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportLandlordReportingSales]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

create table #StagingLandlordSales
   ([Company] [int] NOT NULL,
	[Store] [int] NOT NULL,
	[Fiscal_Year] [int] NOT NULL,
	[Actual_Year] [int] NOT NULL,
	[Acct_Period] [int] NOT NULL,
	[NetSales] [decimal](18, 2) NULL,
	[MCCSales] [decimal](18, 2) NULL,
	[Refunds] [decimal](18, 2) NULL,
	[Discounts] [decimal](18, 2) NULL)

insert into #StagingLandlordSales
Select Company, Store, Fiscal_Year, Actual_Year, Acct_Period, NetSales, MCCSales, Refunds, Discounts  from openquery (bkl400, 
'select
Company,
Acct_Unit as Store,
Fiscal_Year,
Fiscal_Year-1 as Actual_Year,
Acct_Period+1 as Acct_Period,
sum(case when account > 399999 and account < 499999 then Acct_Amount end)* -1 as NetSales,
sum(case when account = 490000 then acct_Amount end)* - 1 as MCCSales,
sum(case when account = 401000 then acct_Amount end ) as Refunds,
sum(case when account between 403000 and 409000 then acct_Amount end) as Discounts, Account
from law10db.dbglglt 
where Company = 300 and acct_Period in (1,2,3,4,5,6,7,8,9,10,11) and Fiscal_Year between 2022 and 2023
group by Fiscal_Year, Acct_Period, Acct_Unit, Company, Account
order by Fiscal_Year, Acct_Period')
union 
Select Company, Store, Fiscal_Year, Actual_Year, Acct_Period, NetSales, MCCSales, Refunds, Discounts from openquery (bkl400, 
'select
Company,
Acct_Unit as Store,
Fiscal_Year+1 as Fiscal_Year,
Fiscal_Year as Actual_Year,
case when acct_period = 12 then 1 end as Acct_Period,
sum(case when account > 399999 and account < 499999 then Acct_Amount end)* -1 as NetSales,
sum(case when account = 490000 then acct_Amount end)* - 1 as MCCSales,
sum(case when account = 401000 then acct_Amount end ) as Refunds,
sum(case when account between 403000 and 409000 then acct_Amount end) as Discounts, Account
from law10db.dbglglt 
where Company = 300 and Acct_Period = 12 and Fiscal_Year between 2022 and 2023
group by Fiscal_Year, Acct_Period, Acct_Unit, Company, Account
order by Fiscal_Year, Acct_Period')

INSERT INTO [dbo].[LandlordReportingSales]
           ([Company]
           ,[Store]
           ,[Fiscal_Year]
           ,[Actual_Year]
           ,[Acct_Period]
           ,[NetSales]
           ,[MCCSales]
           ,[Refunds]
           ,[Discounts])

Select t.Company
           ,t.Store
           ,t.Fiscal_Year
           ,t.Actual_Year
           ,t.Acct_Period
           ,t.NetSales
           ,t.MCCSales
           ,t.Refunds
           ,t.Discounts
		   from #StagingLandlordSales t left join
		   LandlordReportingSales lls on t.Store = lls.Store and t.Company = lls.Company and t.Fiscal_Year = lls.Fiscal_Year and t.Actual_Year = lls.Actual_Year and t.Acct_Period = lls.Acct_Period
		   where lls.Acct_Period is null and lls.Fiscal_Year is null and lls.Store is null

/****incase there are changes****/
update lls
set lls.NetSales = t.NetSales, lls.MCCSales = t.MCCSales, lls.Refunds = t.Refunds, lls.Discounts = t.Discounts
from LandlordReportingSales lls inner join
#StagingLandlordSales t on t.Store = lls.Store and t.Company = lls.Company and t.Fiscal_Year = lls.Fiscal_Year and t.Actual_Year = lls.Actual_Year and t.Acct_Period = lls.Acct_Period

drop table #StagingLandlordSales

create  table #tempSalesAccounts (
Company int,
Account int,
Acct_Unit int
)

insert into #tempSalesAccounts
Select distinct Company, Account, Acct_Unit from openquery (bkl400, 
'Select 
Company,
Account,
Acct_Unit 
from law10db.dbglglt
where Company = 300 and Account > 399999 and account < 499999 ')

insert into LandlordReportingAccounts
Select
t.Company,
t.Account,
t.Acct_unit as Store 
from #tempSalesAccounts t left join
LandlordReportingAccounts l on t.Company = l.Company and t.Acct_Unit = l.store
where l.Account is null


drop table #tempSalesAccounts
END
GO
