USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateINVCBL]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_MigrateINVCBL]
as
begin
Truncate table INVCBL;

Insert into INVCBL(
Sku_Number, Dept,SDept, Class, SClass, Vendor,On_Hand, Wk1Sales, Wk2Sales, Wk3Sales, Wk4Sales, Wk5Sales,
Wk6Sales, Wk7Sales, Wk8Sales, AvgCost, AvgOnHand, AvgRetail, AvgInvCost,  POOOnOrder, TrfOnOrder, InTransit, LifeToDateUnits,
LifeToDateDollars, Load_Date
)

Select Sku_Number, Dept,SDept, Class, SClass, Vendor,On_Hand, Wk1Sales, Wk2Sales, Wk3Sales, Wk4Sales, Wk5Sales,
Wk6Sales, Wk7Sales, Wk8Sales, AvgCost, AvgOnHand, AvgRetail, AvgInvCost,  POOOnOrder, TrfOnOrder, InTransit, LifeToDateUnits,
LifeToDateDollars, Load_Date from openquery (bkl400,'Select 
t1.INUMBR as Sku_Number, t1.CBDEPT as Dept,t1.CBSDPT as SDept, t1.CBCLAS as Class, t1.CBSCLS as SClass, t1.CBVNDR as Vendor, t1.CBHAND as On_Hand, 
t1.CBWK01 as Wk1Sales, t1.CBWK02 as Wk2Sales, t1.CBWK03 as Wk3Sales, t1.CBWK04 as Wk4Sales, t1.CBWK05 as Wk5Sales,t1.CBWK06 as Wk6Sales, 
t1.CBWK07 as Wk7Sales, t1.CBWK08 as Wk8Sales, t1.CBAVGC as AvgCost, t1.CBAVOH as AvgOnHand, t1.CBAVRT as AvgRetail, t1.CBAVCS as AvgInvCost, 
t1.CBPOOQ as POOOnOrder, t1.CBTOOQ as TrfOnOrder, t1.CBINTQ as InTransit, t1.CBMASU as LifeToDateUnits,t1.CBMASD as LifeToDateDollars, 
CURRENT_TIMESTAMP as Load_Date
from mm4r4lib.invcbl t1 inner join
mm4r4lib.invmste t2 on t1.inumbr = t2.inumbr') ;
end
GO
