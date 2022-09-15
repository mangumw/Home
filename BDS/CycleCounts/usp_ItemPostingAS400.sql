USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ItemPostingAS400]    Script Date: 8/12/2022 1:08:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/23/2021
-- Description:	Posting to AS400
-- =============================================
ALTER PROCEDURE [dbo].[usp_ItemPostingAS400] 
AS

--Declare @Store int
--set @Store = (select distinct StoreNumber from tblBatches where StoreNumber IN ( select StoreNumber from tblBatches where StatusID = 2))

--declare posting_cur cursor for             
--SELECT Distinct StoreNumber from [dbo].tblBatches where StatusID = 2
--open posting_cur                                        

--fetch next from posting_cur into   
--@Store
--while @@fetch_status = 0       
--begin       
/****************************************************Delete from tblScannedItems where Department has HASH*******************************************************************/
--delete from tblScannedItems where Department like '%HASH%'

 /******************************************Update Scanned Items Price and Action Alley Location where there is a null Value**************************************/
update si
set si.RetailPrice = bd.RetailPrice, si.ActionAllyPlacement = bd.ActionAllyPlacement
--Select bd.sku, si.sku, bd.BatchPass, si.BatchPass, bd.BatchNumber, si.BatchNumber, bd.RetailPrice, si.RetailPrice, bd.ActionAllyPlacement
from tblScannedItems si left join
tblBatchDetails bd on si.StoreNumber = bd.StoreNumber and si.sku = bd.SKU 
where si.ActionAllyPlacement is null and si.RetailPrice is null --and si.BatchPass in (3,4,5,6,7) 
Print 'Update AA Location and Price'
--/*************************************Pulls Limit from as400**************************************/
--create table #tmpStoreCnt (
--StoreNumber int,
--Date varchar(8),
--Count1 int,
--Count2 int,
--Count3 int,
--Count4 int,
--Count4Add int
--)
--insert into #tmpStoreCnt
--Select StoreNumber, Date, Count1, Count2, Count3, Count4, Count4Add 
--from openquery (bkl400, 'Select CSISTORE as StoreNumber, CSIDYDTE as Date, CSIDYCNT1 as Count1, CSIDYCNT2 as Count2, CSIDYCNT3 as Count3, CSIDYCNT4 as Count4,
--CSIDYCNT99 as Count4Add 
--from MM4R4LIB.cyctstore')

--insert into tblCountItems
--Select * from #tmpStoreCnt
--drop table #tmpStoreCnt

--Create table #tmpAllItemsEOD(
--Storenumber int,
--AllItems int
--)
--insert into #tmpAllItemsEOD
--Select StoreNumber, sum(Count1)+sum(Count2)+sum(Count3)+sum(Count4)+sum(Count4Add) as AllItems 
--from tblCountItems
--Group by StoreNumber

--Declare @ItemCount int = (Select * from #tmpAllItemsEOD where StoreNumber = @Store)


----Checks to see if items count is  less than 1800 items if so posting will not happen
--/*************************************************Checks to see if item number has been reach, if not adds more, if met then stops executing*************************************/
--Create table #tmp_Count (
--[Total Item Count] varchar (4)
--)
--insert into #tmp_Count
--Select count(si.ScanID) as [Total Item Count] 
--from tblScannedItems si inner join
--tblBatches b on si.BatchNumber = b.BatchNumber and si.BatchPass = b.BatchPass and si.StoreNumber = b.StoreNumber
--where si.StoreNumber = @Store

--IF EXISTS (Select * from #tmp_Count where [Total Item Count] <@ItemCount)

--BEGIN
--exec [dbo].[usp_ImportAddsToBatch4] @Store
-- drop table #tmp_Count
--RETURN

--END

--Do a check for Variance batch not being closed and exec rollback
/***********************************************Check if Variance Batch is closed and and if not do not Continue*************************************************/

--IF EXISTS (Select * from tblBatches where BatchPass in (3,4,5,6,7) and StatusID = 5 and Storenumber = @Store)

--BEGIN
--exec [dbo].[usp_ImportVarianceRollBack] @Store


--RETURN

--END
--BEGIN

/*********************************************************Create temp table for Batch 5 items and removes duplicates*****************************************/
create table #temp_Batch5Clean (
Storenumber int,
Sku int,
ScannedCnt int,
DateCreated Date
)

insert into #temp_Batch5Clean (
Storenumber,
Sku,
ScannedCnt,
DateCreated
)

 Select  
 s.StoreNumber,
 s.SKU, 
 s.ScannedCnt,
 cast(s.DateCreated as Date) as DateCreated
 from tblScannedItems s
 where BatchPass  = (Select Max(BatchPass) from tblScannedItems s1 where s.storenumber = s1.Storenumber and s.BatchNumber = s1.BatchNumber and s.sku = s1.sku) and 
 BatchNumber = 5
 order by SKU

/**************************************************Send command to as400 sql server command table********************************************/
  create table #tmp1(
  Name varchar (6),
  BatchNumber varchar(2),
  StoreNumber varchar(5)
  )
  insert into #tmp1
  Select Distinct
  'UPLOAD' as Name,
  si.BatchNumber,
  --convert(varchar (2), isnull(( select max(isnull(BatchNumber,0))  from tblBatches ),1)) as BatchNumber,
  --cast(@Store as varchar (5)) as 
  b.StoreNumber
  from tblStores s inner join
  tblBatches b on s.StoreNumber = b.StoreNumber and StatusID = 2 inner join
  tblScannedItems si on b.StoreNumber = si.StoreNumber
  where ItemPosted = 0 and b.StatusID = 2

--Select * from openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, cast(getdate() as Date) SSC_TIME from #tmp1
--DROP TABLE #tmp1
/***************************************************Batches 1-4 insert***************************************************/
--Select * from openquery (bkl400, 'Select * from MM4R4LIB.CYCTPIE')
insert openquery (bkl400,'Select CPISTORE, CPINUMBR, CPSCNCNT,CPINSTIM from MM4R4LIB.CYCTPIE')
--Select * from openquery 
Select 
s.StoreNumber as CPISTORE,
s.SKU as CPINUMBR,
s.ScannedCnt as CPSCNCNT,
cast(s.DateCreated as Date) as CPINSTIM 
from tblScannedItems s inner join
tblBatches b on s.StoreNumber = b.StoreNumber and s.BatchNumber = b.BatchNumber and b.BatchPass = s.BatchPass
WHERE b.StatusID = 2 and s.BatchNumber <> 5 and s.ItemPosted = 0

/**********************************************************Batch 5 Insert*********************************************************************/
insert openquery (bkl400,'Select CPISTORE, CPINUMBR, CPSCNCNT,CPINSTIM from MM4R4LIB.CYCTPIE')
Select
s.StoreNumber as CPISTORE,
s.SKU as CPINUMBR,
s.ScannedCnt as CPSCNCNT,
cast(s.DateCreated as Date) as CPINSTIM 
from #temp_Batch5Clean s



/***************************************************Updates items to posted in tblScannedItems table*******************************************/
Update tblScannedItems
set ItemPosted = 1
from tblBatches b inner join
tblScannedItems si on b.storenumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass
where b.StatusID = 2 and si.ItemPosted = 0

drop table #temp_Batch5Clean
drop table #tmp1

--fetch next from posting_cur into  
--@Store
--end    
--close posting_cur   
--deallocate posting_cur

--end