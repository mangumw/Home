USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_C4ImportAddsToBatch4_NOTBEINGUSED]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/14/2021
-- Description:	Adds to Batch 4 only to make 1800 items
-- =============================================
CREATE PROCEDURE [dbo].[usp_C4ImportAddsToBatch4_NOTBEINGUSED] @Store int

AS
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

Create table #tmpScannedItems(
StoreNumber varchar(25),
OnHand int,
ScannedCnt int
)

insert into #tmpScannedItems
(StoreNumber, onhand, ScannedCnt)
Select StoreNumber, OnHand, ScannedCnt from tblScannedItems where StoreNumber = @Store and ScannedCnt = 0

update #tmpScannedItems
set ScannedCnt = OnHand
--Select * 
from #tmpScannedItems
where ScannedCnt = 0 and StoreNumber = @Store


--drop table #tmpStoreCnt
truncate table tblCountItems
/*************************************Pulls Limit from as400**************************************/
create table #tmpStoreCnt (
StoreNumber int,
Date Date,
Count1 int,
Count2 int,
Count3 int,
Count4 int,
Count4Add int,
Count5 int
)
insert into #tmpStoreCnt
Select StoreNumber, Date, Count1, Count2, Count3, Count4, Count4Add, Count5 
from openquery (bkl400, 'Select CSISTORE as StoreNumber, DATE( TIMESTAMP_FORMAT(cast(CSIDYDTE as varchar(8)), ''YYYYMMDD''))  as Date, CSIDYCNT1 as Count1, CSIDYCNT2 as Count2, CSIDYCNT3 as Count3, CSIDYCNT4 as Count4,
CSIDYCNT99 as Count4Add, CSIDYCNT5 as Count5 
from MM4R4LIB.cyctstore')

insert into tblCountItems
Select * from #tmpStoreCnt
drop table #tmpStoreCnt
print 'Insert into tblCount table'

Create table #tmpAllItemsEOD(
Storenumber int,
AllItems int
)
insert into #tmpAllItemsEOD
Select StoreNumber, sum(Count1)+sum(Count2)+sum(Count3)+sum(Count4)+sum(Count4Add) as AllItems 
from tblCountItems where StoreNumber = @Store and Date = (Select max(Date) as Date from tblCountItems)
Group by StoreNumber
print 'Create AllitemEOD temp table for count'

Declare @ItemCount int = (Select AllItems+sum(ScannedCnt) as AllItems 
from #tmpAllItemsEOD a inner join
#tmpScannedItems s on a.StoreNumber = s.StoreNumber
where a.Storenumber = @Store group by AllItems)


--Checks to see if 1800 items have been met, if it has it stops executing
/*************************************************Checks to see if item number has been reach, if not adds more, if met then stops executing*************************************/
Create table #tmp_Count (
[Total Item Count] varchar (4)
)
insert into #tmp_Count
Select sum(si.ScannedCnt) as [Total Item Count] 
from tblScannedItems si inner join
tblBatches b on si.BatchNumber = b.BatchNumber and si.BatchPass = b.BatchPass and si.StoreNumber = b.StoreNumber
where si.StoreNumber = @Store
print 'Temp Count Table for <=ItemCount'

IF EXISTS (Select * from #tmp_Count where [Total Item Count] >=@ItemCount)

BEGIN
 Print 'Items has been met for Batches 1 through 4, Batch 5 will now be created'

/****************************************************Requests next batch from as400***********************************************/
exec [dbo].[usp_RequestNextBatch] @Store;

/*****************************************Insert for Batch 5*************************************************/
if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 1 and BatchNumber = 5 and Storenumber = @Store
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select top 1 
  '5' as BatchNumber, 
  '1' as BatchPass, 
  StoreNumber,
  'Batch 5' as Description, 
  '3' as StatusID 
  from tblBatches
  where StoreNumber = @Store
  end

/**************************************************Inserts/Scrubs all data************************************************************/
truncate table tblStagingBatchDetails;


insert into tblStagingBatchDetails (
SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

select SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand,RetailPrice
from openquery (bkl400, 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from MM4R4LIB.CYCTBATCH') where Storenumber = @Store

--Select * from tblStagingBatchDetails
/*************************************************************Inserts in Batch Details table***************************************************/
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct b.BatchNumber, b.BatchPass, st.SKU, st.Manufactures,st.[Description], st.Author, st.Department, st.SubDepartment, 
st.SubClass, st.StoreNumber, st.ActionAllyPlacement, st.OnHand, st.RetailPrice
from tblStagingBatchDetails st left join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.SKU = bd.SKU inner join
tblBatches b on st.StoreNumber = b.StoreNumber
where b.BatchDate = dateadd(dd,datediff(dd,0,getdate()),0) and st.StoreNumber = @Store and b.StatusID = 3
/********************************************************Send Batch Item Report***********************************************************/

exec [dbo].[usp_StoreBatchItemReport] @Store

 drop table #tmp_Count


 --Added 11072021 1039AM
 update tblBatches
 set StatusID = 2
 where BatchNumber = 4 and BatchPass = 8 

RETURN
print 'If Statement for <=ItemCount and Batch 5 Created and Inserts Items'
END
/*********************************************If @itemsCount is not met then Batch will be inserted for next pass for Batch4***************************************************/
exec usp_CreateSupplementBatch4ByStore @Store

begin
/****************************************************Requests next batch from as400***********************************************/
exec [dbo].[usp_RequestNextBatch4] @Store

print 'usp_Request Next Batch'
/**************************************************Inserts/Scrubs all data************************************************************/
truncate table tblStagingBatchDetails


insert into tblStagingBatchDetails (
SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

select SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand,RetailPrice
from openquery (bkl400, 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from MM4R4LIB.CYCTBATCH') where Storenumber = @Store
print 'insert into tblStaging'

/*************************************************************Inserts in Batch Details table***************************************************/
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
Declare @Items int
Declare @Limit int
set @Items = (Select count(*) from tblStagingBatchDetails where Storenumber = @Store)
Set @Limit = (Select AllItems from #tmpAllItemsEOD where StoreNumber = @Store)

insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select top (@Limit-@Items) b.BatchNumber, b.BatchPass, st.SKU, st.Manufactures,st.[Description], st.Author, st.Department, st.SubDepartment, 
st.SubClass, st.StoreNumber, st.ActionAllyPlacement, st.OnHand, st.RetailPrice
from tblStagingBatchDetails st left join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.SKU = bd.SKU inner join
tblBatches b on st.StoreNumber = b.StoreNumber
where b.BatchDate = dateadd(dd,datediff(dd,0,getdate()),0) and st.StoreNumber = @Store and b.StatusID = 3
print 'insert into tblBatchDetails'

/************************************************************Add items missed from previous bacthes into tblBatchDetails******************************************************/
insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
from tblBatchDetails bd 
where SKU not in (Select SKU from tblScannedItems where Storenumber = @Store and BatchNumber in (1,2,3,4) and BatchPass in (1,2)) 
and StoreNumber = @Store and BatchNumber in (1,2,3,4) and BatchPass in (1,2)
print 'Adds Missing Items Skipped back into tblBatchDetails'

/********************************************************Send Batch Item Report***********************************************************/

drop table #tmpAllItemsEOD
drop table #tmpScannedItems

exec [dbo].[usp_StoreBatchItemAddTo4Report] @Store
print 'execute Store Item Report'
end



GO
