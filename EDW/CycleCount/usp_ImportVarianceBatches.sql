USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportVarianceBatches]    Script Date: 8/12/2022 12:22:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/06/2021
-- Description: Deletes and Inserts Variance Items
-- =============================================
ALTER PROCEDURE [dbo].[usp_ImportVarianceBatches] @Store int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))


 /******************************************Update Scanned Items Price and Action Alley Location where there is a null Value**************************************/
update si
set si.RetailPrice = bd.RetailPrice, si.ActionAllyPlacement = bd.ActionAllyPlacement
--Select bd.sku, si.sku, bd.BatchPass, si.BatchPass, bd.BatchNumber, si.BatchNumber, bd.RetailPrice, si.RetailPrice, bd.ActionAllyPlacement
from tblScannedItems si left join
tblBatchDetails bd on si.StoreNumber = bd.StoreNumber and si.sku = bd.SKU 
where bd.StoreNUmber = @Store and si.ActionAllyPlacement is null and si.RetailPrice is null --and si.BatchPass in (3,4,5,6,7) 
Print 'Update AA Location and Price'
/****************************************Good Items from Scanned Items to Scanned Items*********************************/
----drop table #tmpVIC
 Create table #tmpVIC(
BatchNumber int, 
BatchPass int, 
SKU int, 
Manufactures int,
Description varchar (100), 
Author varchar (100), 
Department varchar (100), 
SubDepartment varchar (100), 
SubClass varchar (100), 
StoreNumber int, 
ActionAllyPlacement varchar (500), 
OnHand int, 
ScannedCnt int,
RetailPrice decimal (18,2),
Difference int
)
insert into #tmpVIC
Select  
si.BatchNumber, si.BatchPass, si.SKU, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, 
si.ActionAllyPlacement, si.OnHand, si.ScannedCnt, si.RetailPrice,(bd.OnHand-si.ScannedCnt) as Difference
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
Where bd.StoreNumber = @Store  and b.StatusID = 3
Print 'Temp Table VIC created for 1,2 to not delete <> 0 or <> 1 in difference'

--drop table #tmpVIC2
 Create table #tmpVIC2(
BatchNumber int, 
BatchPass int, 
SKU int, 
Manufactures int,
Description varchar (100), 
Author varchar (100), 
Department varchar (100), 
SubDepartment varchar (100), 
SubClass varchar (100), 
StoreNumber int, 
ActionAllyPlacement varchar (500), 
OnHand int, 
RetailPrice decimal (18,2),
Difference int
)
Print 'Created VIC2 for passes 3,4,5,6,7'
/*******************************Inserts for pass 3,4,5,6,7 after intial pass*****************************************/
insert into #tmpVIC2
Select  
si.BatchNumber, si.BatchPass, si.SKU, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, 
si.ActionAllyPlacement, si.OnHand, si.RetailPrice,(bd.OnHand-si.ScannedCnt) as Difference
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
Where bd.StoreNumber = @Store  and b.StatusID = 5
Print 'Insert for passes 3,4,5,6,7 temp table'




/**********************************Insert for Variance Report after Intial Scan and Last Scan***************************************/
insert into tblVarianceItems
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,si.SubClass,si.StoreNumber,
si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.BatchPass = si.BatchPass and bd.SKU = si.SKU
where bd.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and b.StatusID = 5
Print 'Insert into tblVarianceItems'
/*********************************************Copies Previous Variance pass into temp table for comparision*********************************/
Create table #tmpVariance(
BatchNumber int,
BatchPass int,
SKU int,
Manufactures int,
Description varchar (100),
Author varchar (100),
Department varchar (100),
SubDepartment [varchar](100),
SubClass [varchar](100),
StoreNumber int,
ActionAllyPlacement [varchar](500),
OnHand int,
ScannedCnt int,
RetailPrice decimal (18,2),
DateCreated datetime,
CreatedBy  varchar (100),
Difference int
)
insert into #tmpVariance
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,si.SubClass,si.StoreNumber,
si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy, (bd.OnHand-si.ScannedCnt) as Difference
from tblScannedItems si inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber and si.BatchPass = b.BatchPass inner join
tblBatchDetails bd on si.storenumber = bd.StoreNumber and si.BatchNumber = bd.BatchNumber and si.BatchPass = bd.BatchPass and si.sku = bd.sku
where si.StoreNumber = @Store and si.ScannedCnt <> bd.OnHand --or si.RetailPrice != bd.RetailPrice
and si.BatchPass in (3,4,5,6,7) and b.StatusID = 5 
Print 'Insert into #tmpVariance'


/********************************Deletes Changes from previous variance scan**************************************/

Delete bd
--Select bd.*
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass 
where bd.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and b.StatusID = 5

/* Orginal Placement - Do not use move to Variance Report proc
Delete si
--Select si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass 
where b.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and b.StatusID = 5
*/

/************************************************Insert data back into Batch Details**********************************************************/
insert into tblBatchDetails (BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice)
Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice
from #tmpVariance
where Storenumber = @Store and RetailPrice > 25.00 and Difference !=0
Print 'Insert into tblBatchDetails from #tmpVariance greater than 25.00'

insert into tblBatchDetails (BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice)
Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice
from #tmpVariance
where Storenumber = @Store and Difference !=1 and Difference !=-1 and RetailPrice < 25.00
Print 'Insert into tblBatchDetails from #tmpVariance less than 25.00'

Drop table #tmpVariance


--Moved 25.00 Delete to past the variance report at end

--Delete si
----Select  t.Difference, si.*
--from tblBatches b inner join
--tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
--#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
--where b.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and t.Difference != 0 and Difference != 1 and Difference !=-1 and si.RetailPrice < 25.00

--Print 'Deleted items from Scanned Items Table less then 25.00'
--Added for 25.00 227PM 10.13.2021
/***********************Updates variance items to orginal pass after good scan*********************************************/
update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 1')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 1')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 1 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 1 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 2')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (4) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 2')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (4)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 2 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (4) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 2 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (4)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 3')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (5) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 3')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (5)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 3 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (5) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 3 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (5)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 4')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (6) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 4')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (6)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 4 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (6) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 4 Continued')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (6)and t.RetailPrice > 25.00 and Difference = 0

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 5')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (7) and t.RetailPrice < 25.00 and Difference =-1 or Difference = 0 or Difference = 1 

update si
set si.BatchPass = (Select b1.BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Batch 5')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (7)and t.RetailPrice > 25.00 and Difference = 0
Print 'Update BatchPass'

/*************************************Check to see if add to batch 4 if not Imports variance *****************************************************/
--IF EXISTS (Select BatchNumber from tblBatches where BatchPass in (1,2,3,4,5,6) and StatusID = 2)

--BEGIN
--exec [dbo].[usp_ImportAddsToBatch4] @Store
-- drop table #tmp_Count

--RETURN

--END

/***********************************Checks to see if it already exists, if it does it stops execution**************************************/
IF EXISTS (Select * from tblBatches where BatchPass in (3,4,5,6,7) and StatusID = 5 and Storenumber = @Store)

BEGIN
exec dbo.usp_StoreVarianceReport @Store

RETURN
	END


/*************************************************Creates Batch Number************************************************/

exec dbo.usp_CreateVarianceBatchByStore @Store;
--Print ' Added Variance Batch'

/*************************************************************Inserts in Batch Details table, First Pass through***************************************************/
--Declare @store int = @Store
--drop table tmp_VarianceItems
--Create table tmp_VarianceItems (
--	[BatchNumber] [int] NOT NULL,
--	[BatchPass] int,
--	[SKU] [varchar](25) NOT NULL,
--	[Manufactures] [varchar](50) NULL,
--	[Description] [varchar](100) NULL,
--	[Author] [varchar](100) NULL,
--	[Department] [int] NULL,
--	[SubDepartment] [int] NULL,
--	[SubClass] [int] NULL,
--	[StoreNumber] [int] NULL,
--	[ActionAllyPlacement] [nchar](10) NULL,
--	[OnHand] [int] NULL,
--	[Difference] int,
--	RetailPrice decimal(18,2)
--)

--drop table #tmpCount
 Create table #tmpCount(
StoreNumber int,
Difference int,
sku int,
BatchNumber int,
RetailPrice decimal (18,2),
OnHand int,
ScannedCnt int
)
 insert into #tmpCount
Select Distinct bd.StoreNumber,
(bd.OnHand-si.ScannedCnt) as Difference, bd.sku, bd.BatchNumber, bd.RetailPrice, bd.OnHand, si.ScannedCnt
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
Where bd.StoreNumber = @Store and bd.BatchPass in (1,2) --and b.StatusID = 3
--Print 'Inserted into #tmpCount for Batch 1 Pass 1 items that do not match'

--Batch 1
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 3 and Batchnumber = 1 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '3' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1 or t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '3' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 5 --and b.Description like 'Var%'
)
--Select * from tmp_VarianceItems

 insert into tblBatchDetails(BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct q.BatchNumber, q.BatchPass, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.RetailPrice
from cte_qty q 
union 
Select distinct a.BatchNumber, a.BatchPass, a.sku, a.Manufactures, a.Description, a.Author, a.Department, a.SubDepartment, a.SubClass, 
a.StoreNumber, a.ActionAllyPlacement, a.OnHand, a.RetailPrice
from cte_amount a 
end
--Print 'Inserted Batch 1 Pass 3'

--Batch 2
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 4 and Batchnumber = 2 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '4' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1 or t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '4' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 5 --and b.Description like 'Var%'
)
--Select * from tmp_VarianceItems

 insert into tblBatchDetails(BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct q.BatchNumber, q.BatchPass, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.RetailPrice
from cte_qty q 
union 
Select distinct a.BatchNumber, a.BatchPass, a.sku, a.Manufactures, a.Description, a.Author, a.Department, a.SubDepartment, a.SubClass, 
a.StoreNumber, a.ActionAllyPlacement, a.OnHand, a.RetailPrice
from cte_amount a 
end
--Print 'Inserted Batch 2 Pass 4'

  --Batch 3
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 5 and Batchnumber = 3 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '5' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1 or t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '5' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 5 --and b.Description like 'Var%'
)
--Select * from tmp_VarianceItems

 insert into tblBatchDetails(BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct q.BatchNumber, q.BatchPass, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.RetailPrice
from cte_qty q 
union 
Select distinct a.BatchNumber, a.BatchPass, a.sku, a.Manufactures, a.Description, a.Author, a.Department, a.SubDepartment, a.SubClass, 
a.StoreNumber, a.ActionAllyPlacement, a.OnHand, a.RetailPrice
from cte_amount a 
end
--Print 'Inserted Batch 3 Pass 5'

  --Batch 4
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 6 and Batchnumber = 4 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '6' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1 or t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '6' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 5 --and b.Description like 'Var%'
)
--Select * from tmp_VarianceItems

 insert into tblBatchDetails(BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct q.BatchNumber, q.BatchPass, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.RetailPrice
from cte_qty q 
union 
Select distinct a.BatchNumber, a.BatchPass, a.sku, a.Manufactures, a.Description, a.Author, a.Department, a.SubDepartment, a.SubClass, 
a.StoreNumber, a.ActionAllyPlacement, a.OnHand, a.RetailPrice
from cte_amount a 
end
--Print 'Inserted Batch 4 Pass 6'


  --Batch 5
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 7 and Batchnumber = 5 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '7' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1 or t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '7' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 5 --and b.Description like 'Var%'
)
--Select * from tmp_VarianceItems

 insert into tblBatchDetails(BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct q.BatchNumber, q.BatchPass, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.RetailPrice
from cte_qty q 
union 
Select distinct a.BatchNumber, a.BatchPass, a.sku, a.Manufactures, a.Description, a.Author, a.Department, a.SubDepartment, a.SubClass, 
a.StoreNumber, a.ActionAllyPlacement, a.OnHand, a.RetailPrice
from cte_amount a 
end
--Print 'Inserted Batch 5 Pass 7'



/*************************************************Insert for Intial Scan**************************************************/
insert into tblVarianceItems
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,
si.SubClass,si.StoreNumber,si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.BatchPass = si.BatchPass and bd.SKU = si.SKU
where bd.StoreNumber = @Store and b.BatchPass in (1,2) --and b.StatusID = 5

/************************************************************Insert for After Inital Scan***************************************************/
insert into tblVarianceItems
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,
si.SubClass,si.StoreNumber,si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.BatchPass = si.BatchPass and bd.SKU = si.SKU
where bd.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and b.StatusID = 5


--drop table tmp_VarianceItems
/******************************************************Send Variance Report*************************************************/
if EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchPass in (3,4,5,6,7) and StatusID = 5)
begin
exec dbo.usp_StoreVarianceReport @Store 
print 'Sent Variance Report Executing from Import Variance Proc'


--Deletes and Updates for Variance Items
/****************************************************Deletes items out of intial scan for Onhand and scanned items that do not match****************************************/
Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (1,2) and t.Difference != 0 and si.RetailPrice >25.00
Print 'Deleted items from Scanned Items Table greater than 25.00'

Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (1,2) and t.Difference != 0 and Difference != 1 and Difference !=-1 and si.RetailPrice < 25.00
Print 'Deleted items from Scanned Items Table less then 25.00'

/****************************************************Deletes items out of 3,4,5,6,7 scan for Onhand and scanned items that do not match****************************************/
Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and t.Difference != 0 and Difference != 1 and Difference !=-1 --and si.RetailPrice < 25.00
Print 'Deleted items from Scanned Items Table'

/***************************************************25.00 Threshold****************************/
Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC2 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass in (3,4,5,6,7) and t.Difference != 0 and si.RetailPrice >25.00
Print 'Deleted items from Scanned Items Table greater than 25.00'

Drop table #tmpCount
drop table #tmpVIC
drop table #tmpVIC2
end
else
--Add count to execute for supplemntal bacthes if buisness wants it done this way

/*************************************Check to see if add to batch 4, if not Imports variance *****************************************************/
IF EXISTS (Select BatchNumber from tblBatches where BatchNumber = 4 and BatchPass = 6 and StatusID = 2 and StoreNumber = @Store and
NOT EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber = 5 and BatchPass = 7))

BEGIN
exec [dbo].[usp_ImportVarianceSupplement4] @Store
 --drop table #tmp_Count



END

END


