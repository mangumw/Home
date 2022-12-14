USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportVarianceRollBack]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/23/2021
-- Description:	Zero out OnHands scanned, Remove Variance Batch, and create new Varaince Batch
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportVarianceRollBack] @Store int

AS
BEGIN
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

declare rollback_cur cursor for             
SELECT Distinct StoreNumber from [dbo].tblBatches
open rollback_cur                                        

fetch next from rollback_cur into   
@Store
while @@fetch_status = 0       
begin    

--Delete Batch Passes for variance Batches to start them at zero if not finished by posting
Delete bd
--Select bd.*
from tblBatchDetails bd inner join
tblBatches b on b.storenumber = bd.storenumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass
where bd.Storenumber = @Store and bd.BatchPass in (3,4,5,6,7) and B.StatusID = 5

/* 02/22/2022, took out first where with max batchpass and added sotre, batchpass 3,4,5,6,7 and statusID = 5*/
Delete si
--Select si.*
from tblScannedItems si inner join
tblBatches b on b.storenumber = si.storenumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass
--where si.Storenumber = @Store and si.BatchNumber = (Select max(BatchNumber) from tblBatches where Storenumber = @Store)
Where si.Storenumber = @Store and si.BatchNumber in (3,4,5,6,7) and StatusID = 5


----Rollback scannedCnt to 0 is batch not closed
--Update tblScannedItems
--set ScannedCnt = 0
----Select  b.BatchNumber, S.BatchNumber, s.OnHand, s.ScannedCnt
--from tblScannedItems s inner join
--tblBatches b on s.StoreNumber = b.StoreNumber and s.BatchNumber = b.BatchNumber and s.BatchPass = b.BatchPass
--where  s.StoreNumber = @Store and b.BatchPass not in (1,2) and b.StatusID = 5



/************************************************Insert record into as400 to get update OnHands, this not the query but an example********************************************/
  create table #tmp(
  Name varchar (10),
  BatchNumber varchar(2),
  StoreNumber varchar(5)
  )
  insert into #tmp
  Select top 1
  'ONHAND' as Name,
  convert(varchar (2), isnull(( select max(isnull(BatchNumber,1))+1  from tblBatches ),1)) as BatchNumber,
  cast(@Store as varchar (5)) as StoreNumber
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store

insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, getdate() SSC_TIME from #tmp

--Select * from #tmp

/*********************************************************put into staging table to insert records from as400*****************************************************/
truncate table tblStagingBatchDetails;

insert into tblStagingBatchDetails (
SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

select SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
from openquery (bkl400, 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from MM4R4LIB.CYCTBATCH') where StoreNumber = @Store


/************************************************************Create Update OnHand from temp table items from the as400******************************************/
update bd
set bd.OnHand = st.OnHand
from tblStagingBatchDetails st inner join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.sku = bd.sku inner join
tblBatches b on bd.storenumber = b.storenumber
where bd.StoreNumber = @Store and b.StatusID = 5

/******************************************************************Remove Variance Batch entry and set pass 1 or 2 back to StatusID = 3****************************************/
Delete 
from tblBatches 
where StoreNumber = @Store and StatusID = 5 and BatchNumber = (Select Max(BatchNumber) from tblBatches)

update b
set StatusID = 3
--Select b.*  
from tblBatches b
where StatusID = 2 and StoreNumber = @Store and BatchNumber = (Select Max(BatchNumber) from tblBatches)


fetch next from rollback_cur into  
@Store
end    
close rollback_cur   
deallocate rollback_cur

END

GO
