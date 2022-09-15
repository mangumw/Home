USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportVarianceSupplement4]    Script Date: 8/12/2022 7:06:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/14/2021
-- Description:	Variance for Day 4 Supplement

--11082021 removed statusID = 3 from tmpVIC4 LK
--Added != to 8 for #tmpCount4 table to stop the deletes of pass 8 in scanned items 11/08/2021, Line 182
-- =============================================
ALTER PROCEDURE [dbo].[usp_ImportVarianceSupplement4] @Store int 

AS

set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
--/***********************************Checks to see if it already exists, if it does it stops execution**************************************/
--IF EXISTS (Select * from tblBatches where BatchNumber = 4 and BatchPass = 8 and StatusID = 5 and Storenumber = @Store)

--BEGIN
--exec dbo.usp_StoreVarianceReport @Store
--Print 'Executes Variance Report where Pass = 8 and StatusID = 5 if Already in Batches Table @top of SP'
--RETURN
--	END

--/*********************************************************Add Variance Batch Row insert *****************************************************************/
--IF NOT EXISTS (Select * from tblBatches where BatchNumber = 4 and BatchPass = 8 and StatusID = 5 and Storenumber = @Store)

--BEGIN

--exec [dbo].[usp_CreateVarianceBatchByStore] @Store;
--Print 'Inserting Row to tblBatches for Variance Pass 8 Batch4'
--RETURN
--	END

/*************************************************Updates Variance Batch Number 4************************************************/


update tblBatches
set StatusID = 5
--SELECT BatchNumber, BatchPass, StatusID
FROM tblBatches
WHERE StoreNumber = @Store and BatchNumber = 4 and BatchPass = 8 and StatusID = 2 and  
NOT EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE BatchNumber = 5 and BatchPass = 7);
Print 'Re-Opens Variance Batch from Supplement Batch'

 /******************************************Update Scanned Items Price and Action Alley Location where there is a null Value**************************************/
update si
set si.RetailPrice = bd.RetailPrice, si.ActionAllyPlacement = bd.ActionAllyPlacement
--Select bd.sku, si.sku, bd.BatchPass, si.BatchPass, bd.BatchNumber, si.BatchNumber, bd.RetailPrice, si.RetailPrice, bd.ActionAllyPlacement
from tblScannedItems si left join
tblBatchDetails bd on si.StoreNumber = bd.StoreNumber and si.sku = bd.SKU 
where bd.StoreNUmber = @Store and si.ActionAllyPlacement is null and si.RetailPrice is null --and si.BatchNumber = 4 and bd.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Update AA Location and Price'
/****************************************Good Items from Scanned Items to Scanned Items*********************************/
--drop table #tmpVIC4
 Create table #tmpVIC4(
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
insert into #tmpVIC4
Select Distinct
si.BatchNumber, si.BatchPass, si.SKU, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, 
si.ActionAllyPlacement, si.OnHand, si.ScannedCnt, si.RetailPrice,(bd.OnHand-si.ScannedCnt) as Difference
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
Where bd.StoreNumber = @Store and bd.BatchNumber = 4 and statusID = 2 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Temp Table VIC created for Batch 4 Supplement to not delete <> 0 or <> 1 in difference'


/**********************************Insert for Variance Report after Intial Scan and Last Scan***************************************/
insert into tblVarianceItems
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,si.SubClass,si.StoreNumber,
si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.BatchPass = si.BatchPass and bd.SKU = si.SKU
where bd.StoreNumber = @Store and b.BatchNumber = 4 and b.StatusID = 2 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Insert into tblVarianceItems'
/*********************************************Copies Previous Variance pass into temp table for comparision*********************************/
Create table #tmpVariance4(
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
insert into #tmpVariance4
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,si.SubClass,si.StoreNumber,
si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy, (bd.OnHand-si.ScannedCnt) as Difference
from tblScannedItems si inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber and si.BatchPass = b.BatchPass inner join
tblBatchDetails bd on si.storenumber = bd.StoreNumber and si.BatchNumber = bd.BatchNumber and si.BatchPass = bd.BatchPass and si.sku = bd.sku
where si.StoreNumber = @Store and si.ScannedCnt <> bd.OnHand  and si.BatchNumber = 4 and b.StatusID = 5 and b.BatchPass = 8
Print 'Insert into #tmpVariance'


/********************************Deletes Changes from previous variance scan in Batch Detals**************************************/


Delete bd
--Select bd.*
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass 
where bd.StoreNumber = @Store and b.BatchPass = 8 and b.StatusID = 5
Print 'Deletes Changes from previous variance scan in Batch Detals'

/************************************************Insert data back into Batch Details**********************************************************/
insert into tblBatchDetails (BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice)
Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice
from #tmpVariance4
where Storenumber = @Store and RetailPrice > 25.00 and Difference !=0 --and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Insert into tblBatchDetails from #tmpVariance greater than 25.00'

insert into tblBatchDetails (BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice)
Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,SubClass,StoreNumber,
ActionAllyPlacement,OnHand,RetailPrice
from #tmpVariance4
where Storenumber = @Store and Difference !=1 and Difference !=-1 and RetailPrice < 25.00 --and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Insert into tblBatchDetails from #tmpVariance less than 25.00'

Drop table #tmpVariance4

/***********************Updates variance items to orginal pass after good scan*********************************************/
update si
set si.BatchPass = (Select max(b1.BatchPass) as BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Supplemental Batch')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC4 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass = 8 and t.RetailPrice < 25.00 and  Difference = 1 or Difference =-1 or Difference = 0 --or
Print 'Updates Good Items to Orginal Pass Less than 25.00'

update si
set si.BatchPass = (Select max(b1.BatchPass) as BatchPass from tblBatches b1 where b1.StoreNumber = @Store and b1.Description = 'Supplemental Batch')
--Select  Difference, b.BatchPass, b.Description, si.* 
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC4 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchPass = 8 and t.RetailPrice > 25.00 and Difference = 0
Print 'Updates Good Items to Orginal Pass Greater than 25.00'


--drop table #tmpCount
 Create table #tmpCount4(
StoreNumber int,
Difference int,
sku int,
BatchNumber int,
RetailPrice decimal (18,2),
OnHand int,
ScannedCnt int
) 
-----Added != to 8 for #tmpCount4 table to stop the deletes of pass 8 in scanned items 11/08/2021, Line 182
 insert into #tmpCount4
Select Distinct bd.StoreNumber,
(bd.OnHand-si.ScannedCnt) as Difference, bd.sku, bd.BatchNumber, bd.RetailPrice, bd.OnHand, si.ScannedCnt
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
Where bd.StoreNumber = @Store and bd.BatchNumber = 4 and si.BatchPass !=8 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Inserted into #tmpCount4 for Batch 4 Pass 9+ items that do not match'

--Batch 4 Supplement Variance
 if exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchnumber = 4 and Storenumber = @Store and StatusID = 5
  )
begin
with cte_Qty (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select Distinct si.BatchNumber, '8' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount4 t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1) or (t.[Difference] >1) and b.StatusID = 2 and t.RetailPrice <25.00 --and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
)
,
cte_Amount (BatchNumber, BatchPass, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice)
as (
Select  si.BatchNumber, '8' as BatchPass, si.sku, si.Manufactures, si.Description, si.Author, si.Department, si.SubDepartment, si.SubClass, si.StoreNumber, si.ActionAllyPlacement,
si.OnHand, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount4 t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and t.Difference!=0 and b.StatusID = 2 --and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
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
END
Print 'Inserted Batch 4 Pass 8'

BEGIN
/*************************************************Insert for Intial Scan Batch 4**************************************************/
insert into tblVarianceItems
Select si.BatchNumber,si.BatchPass,si.SKU,si.Manufactures,si.Description,si.Author,si.Department,si.SubDepartment,
si.SubClass,si.StoreNumber,si.ActionAllyPlacement,si.OnHand,si.ScannedCnt,si.RetailPrice,si.DateCreated,si.CreatedBy
from tblBatches b inner join
tblBatchDetails bd on b.StoreNumber = bd.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.BatchPass = si.BatchPass and bd.SKU = si.SKU
where bd.StoreNumber = @Store and b.BatchNumber = 4 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)


/******************************************************Send Variance Report Batch 4*************************************************/
IF exists (Select StoreNumber, BatchNumber, BatchPass, StatusID from tblBatches where StoreNumber = @Store and BatchNumber = 4 and BatchPass = 8 and StatusID = 5)


exec dbo.usp_StoreVarianceBatch4Report @Store 
print 'Sent Variance Report From Import Variance Supplement4 Proc'

--Took out End and Else and included delete inside the IF stmt 11082021 124PM
--END
--ELSE
--BEGIN


/****************************************************Deletes items out of intial scan for Onhand and scanned items that do not match****************************************/
Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC4 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchNumber = 4  and t.Difference != 0 and si.RetailPrice >25.00 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches)
Print 'Deleted items from Scanned Items Table greater than 25.00 Batch 4'

Delete si
--Select  t.Difference, si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass inner join
#tmpVIC4 t on t.StoreNumber = si.StoreNumber and t.BatchNumber = si.BatchNumber and t.BatchPass = si.BatchPass and t.sku = si.sku
where b.StoreNumber = @Store and b.BatchNumber = 4 and b.BatchPass = (Select max(BatchPass) as BatchPass from tblBatches) and (t.Difference != 0) and (Difference != 1) and (Difference !=-1) and si.RetailPrice < 25.00 
Print 'Deleted items from Scanned Items Table less then 25.00 Batch 4'

Print 'Deleted items from Scanned Items Table Batch 4'



Drop table #tmpCount4
drop table #tmpVIC4
--drop table #tmpVIC2
END






