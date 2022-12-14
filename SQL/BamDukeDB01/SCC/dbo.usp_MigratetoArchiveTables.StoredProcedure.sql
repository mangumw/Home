USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigratetoArchiveTables]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 03/15/2022
-- Description:	Move to archive tables for reporting
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigratetoArchiveTables]

AS
BEGIN
begin transaction
begin try

--truncate table tblStores
--insert into tblStores_Arch
--select * from tblStores

insert into tblBatches_Arch (
BatchNumber ,BatchPass ,StoreNumber ,Description ,BatchDate ,StatusID ,DateCreated
	  )
select 
BatchNumber,
BatchPass,
StoreNumber,
Description,
BatchDate,
StatusID,
getdate() as DateCreated 
from tblBatches

insert into tblBatchDetails_Arch (
BatchNumber
,BatchPass
,SKU
,Manufactures
,Description
,Author
,Department
,SubDepartment
,SubClass
,StoreNumber
,ActionAllyPlacement
,OnHand
,RetailPrice
,DateCreated
)
SELECT
BatchNumber
,BatchPass
,SKU
,Manufactures
,Description
,Author
,Department
,SubDepartment
,SubClass
,StoreNumber
,ActionAllyPlacement
,OnHand
,RetailPrice
,getdate() as DateCreated
  FROM dbo.tblBatchDetails

  insert into tblScannedItems_Arch (
  BatchNumber
      ,BatchPass
      ,SKU
      ,Manufactures
      ,Description
      ,Author
      ,Department
      ,SubDepartment
      ,SubClass
      ,StoreNumber
      ,ActionAllyPlacement
      ,OnHand
      ,ScannedCnt
      ,RetailPrice
      ,DateCreated
      ,CreatedBy
      ,ItemPosted
	  )
  Select BatchNumber
      ,BatchPass
      ,SKU
      ,Manufactures
      ,Description
      ,Author
      ,Department
      ,SubDepartment
      ,SubClass
      ,StoreNumber
      ,ActionAllyPlacement
      ,OnHand
      ,ScannedCnt
      ,RetailPrice
      ,DateCreated
      ,CreatedBy
      ,ItemPosted from tblScannedItems

	  COMMIT TRANSACTION;
	  end try
	  begin catch
	  Rollback Transaction;
	  End catch;



truncate table tblBatches
truncate table tblBatchDetails
truncate table tblScannedItems
END

GO
