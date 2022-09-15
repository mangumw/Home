USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_C4CreateSupplementBatch4ByStore_REPLACED]    Script Date: 8/12/2022 1:04:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/15/2021
-- Description:	Bacth 4 Batch Creation Supplement
-- =============================================
ALTER PROCEDURE [dbo].[usp_C4CreateSupplementBatch4ByStore_REPLACED] @Store int 

AS
--THIS DOES NOT CREATE VARIACNE BATCHES!!!
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

IF NOT EXISTS (Select BatchPass from tblBatches where BatchPass in(7,9) and StatusID = 2 and Storenumber = @Store)

BEGIN

update tblBatches
set StatusID = 2
where StoreNumber = @Store and BatchNumber = 4 and Batchpass = (Select max(BatchPass) as BatchPass from tblBatches where BatchNumber not in (8))
and StatusID = 3 

insert into tblBatches values (4,9,@Store, 'Supplemental Batch', getdate (),3)
print 'if 7,9 pass then Max Batch, insert 4 9'

RETURN
 
END

IF EXISTS (Select BatchPass from tblBatches where BatchPass = 9 and Storenumber = @Store)

BEGIN

create table #tmpBatch4 (
BatchNumber int,
BatchPass int,
StoreNumber int,
Description varchar (50),
BatchDate Datetime,
StatusID int
)
  insert into #tmpBatch4
  (BatchNumber, BatchPass, StoreNumber, description, BatchDate, StatusID)

--Select * from tblBatches where storenumber = 111
--After 9 is inserted
  Select top 1
  '4' as BatchNumber,
  max(BatchPass)+1 as BatchPass,
  @Store as StoreNumber,
  'Supplemental Batch' as [Description],
  getdate () as BatchDate,
  '3' as StatusID 
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store 


insert into tblBatches(
BatchNumber, 
BatchPass,
StoreNumber,
[Description],
BatchDate,
Statusid
)
Select BatchNumber, BatchPass,StoreNumber,[Description],BatchDate,Statusid 
from #tmpBatch4

Drop table #tmpBatch4
END

