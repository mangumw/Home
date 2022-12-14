USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateVarianceBatchByStore]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Executes by single store for Variance batch same day
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateVarianceBatchByStore] @Store int
	-- Add the parameters for the stored procedure here
--THIS CREATE VARIANCE BATCH 4
AS
BEGIN
--Declare @Store int
set nocount on
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

update tblBatches
set StatusID = 2
where Storenumber = @Store and StatusID = 3

update tblBatches
set StatusID = 2
--Select * from tblBatches
where StoreNumber = @Store and StatusID = 5

create table #tmpBatch (
BatchNumber int,
BatchPass int,
StoreNumber int,
StatusID int
)
  insert into #tmpBatch
  (BatchNumber, BatchPass, StoreNumber, StatusID)

  Select 
  max(BatchNumber),
  case 
  when BatchNumber = 1 then '3'
  when BatchNumber = 2 then '4'
  when BatchNumber = 3 then '5'
  when BatchNumber = 4 then '6'
  when BatchNumber = 5 then '7' 
  end as BatchPass,
  @Store as StoreNumber,
  '5' as StatusID 
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store and StatusID = 2
  group by BatchNumber



--Batch 1
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 3 and Storenumber = @Store
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber,
  'Variance Batch 1' as Description, 
  StatusID 
  from #tmpBatch
  where BatchNumber = 1 
end

--Batch 2
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 4 and Storenumber = @Store
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber, 
  Description,
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber,
  'Variance Batch 2' as Description,  
  StatusID 
  from #tmpBatch
  where BatchNumber = 2
  end

  --Batch 3
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 5 and Storenumber = @Store and StatusID = 2
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber, 
  'Variance Batch 3' as Description, 
  StatusID 
  from #tmpBatch
  where BatchNumber = 3
  end


  --Batch 4
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 6 and Storenumber = @Store
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber,
  'Variance Batch 4' as Description, 
  StatusID 
  from #tmpBatch
  where BatchNumber = 4
end

  --Batch 5
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Batchpass = 7 and Storenumber = @Store
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber,
  'Variance Batch 5' as Description, 
  StatusID 
  from #tmpBatch
  where BatchNumber = 5

  Update tblBatches
  set StatusID = 2
  where BatchNumber = 4 and BatchPass = 8
end
/*********************************************Batch 4 Variance Supplement**************************************/

create table #tmpBatch4 (
BatchNumber int,
BatchPass int,
StoreNumber int,
StatusID int
)
  insert into #tmpBatch4
  (BatchNumber, BatchPass, StoreNumber, StatusID)

  Select top 1
  '4' as BatchNumber,
  '8' as BatchPass,
  @Store as StoreNumber,
  '5' as StatusID 
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store and BatchNumber = 4 and StatusID = 2 and BatchPass = 6
  group by BatchNumber


--Batch 4 Supplement
  if not exists (Select BatchNumber, 
  BatchPass, StoreNumber, StatusID from tblBatches
  where Storenumber = @Store and BatchNumber = 4 and Batchpass = 8
  )
  begin
  insert into tblBatches( 
  BatchNumber, 
  BatchPass, 
  StoreNumber,
  Description, 
  StatusID 
  )
  Select BatchNumber, 
  BatchPass, 
  StoreNumber,
  'Variance Supp Batch' as Description, 
  StatusID 
  from #tmpBatch4
  where BatchNumber = 4 and storenumber = @Store
end

drop table #tmpBatch
drop table #tmpBatch4
END

--Select * from tblBatches




GO
