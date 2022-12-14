USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportSingleBatches]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Imports 450 Random items from as400 Batches 1-4 Single Batch
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportSingleBatches] @Store int


AS
--declare @Store int = 111
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

exec usp_ExportNonScannedItems @Store;
/***********************************************Check if Single Batch is closed and and if not do not Continue*************************************************/

IF EXISTS (Select BatchNumber, BatchPass, StoreNumber, StatusID 
from tblBatches where BatchPass in (1,2) and StatusID = 3 and Storenumber = @Store)

BEGIN
Print 'Checks Single Batch is Closed and if it is it stops'

RETURN

END

/***********************************************Check if Variance Batch is closed and and if not do not Continue*************************************************/

IF EXISTS (Select * from tblBatches where BatchPass in (3,4,5,6,7,8) and StatusID = 5 and Storenumber = @Store)

BEGIN
print 'Check Variance Status, if open it will stop'

RETURN

END

/**************************************************Check if 1-4 are Closed to Create Batch 4 Supplement***************************************************/

IF EXISTS (Select BatchNumber, BatchPass, StatusID from tblBatches where BatchNumber = 4 and BatchPass = 6 and StatusID = 2 and Storenumber = @Store and
NOT EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber = 4 and BatchPass in(8,9) and StatusID = 2))

BEGIN

exec [dbo].[usp_CreateSupplementBatch4ByStore] @Store;
exec [dbo].[usp_ImportAddsToBatch4] @Store;
print 'Executes batch 4 import'

--this is Trevors proc -- *** This Will email from tblbatchDetails
exec [dbo].[usp_SupplementalBatchEmail] @Store;

RETURN

END


/********************************Check to see if all batches 1-4 are closed and imports batch5 using as400 logical view*****************************/

if EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber = 4 and BatchPass in (6,8,9) and StatusID = 2 and  
NOT EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber = 5 and BatchPass = 7))

BEGIN
exec [dbo].[usp_CreateBatch5] @Store;
exec [dbo].[usp_ImportBatch5] @Store;
print 'Executes Batch 5 Import'

RETURN

END

--ELSE
BEGIN
/****************************************************Requests next batch from as400***********************************************/
exec [dbo].[usp_RequestNextBatch] @Store;
print 'Requests next batch from as400 1-4'

/*********************************************Create New batch row in tblBatches for new items**********************************************/
exec [dbo].[usp_CreateSingleBatchByStore] @Store;
print 'Creates Single Batches by Store'


/**************************************************Inserts/Scrubs all data************************************************************/
delete from tblStagingBatchDetails where Storenumber = @Store;


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
print 'Imports items into tblBatchDetails'
exec [dbo].[usp_StoreBatchItemReport] @Store
print 'Executes Store Batch Report'

END




GO
