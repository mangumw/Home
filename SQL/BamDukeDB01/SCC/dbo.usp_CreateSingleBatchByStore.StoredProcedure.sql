USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateSingleBatchByStore]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Executes by single store for second batch same day
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateSingleBatchByStore] @Store int
	-- Add the parameters for the stored procedure here

AS
BEGIN
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

update tblBatches
set StatusID = 2
where StoreNumber = @Store and StatusID = 3


  insert into tblBatches
  (BatchNumber, BatchPass, StoreNumber, StatusID)

  Select top 1
  max(BatchNumber)+1 as BatchNumber,
  --isnull(( select max(isnull(BatchNumber,1))+1  from tblBatches ),1) as BatchNumber,
  '1' as BatchPass,
  @Store as StoreNumber,
  '3' as StatusID 
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store

  Update tblBatches
  set Description = 'Batch 2'
  Where BatchNumber = 2 and BatchPass = 1

  Update tblBatches
  set Description = 'Batch 3'
  Where BatchNumber = 3 and BatchPass = 1

  Update tblBatches
  set Description = 'Batch 4'
  Where BatchNumber = 4 and BatchPass = 1

  Update tblBatches
  set Description = 'Batch 5'
  Where BatchNumber = 5 and BatchPass = 1
END

--Select * from tblBatches


GO
