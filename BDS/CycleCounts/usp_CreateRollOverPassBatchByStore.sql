USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateRollOverPassBatchByStore]    Script Date: 8/12/2022 1:16:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Executes by single store for second batch same day
-- =============================================
ALTER PROCEDURE [dbo].[usp_CreateRollOverPassBatchByStore] @Store int
	-- Add the parameters for the stored procedure here

AS
BEGIN
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

update tblBatches
set StatusID = 2
--Select * from tblBatches
where StoreNumber = @Store and BatchPass = 1 and StatusID = 3


  insert into tblBatches
  (BatchNumber, BatchPass, StoreNumber, StatusID)

  Select 
  max(BatchNumber) as BatchNumber,
  '2' as BatchPass,
  @Store as StoreNumber,
  '3' as StatusID 
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store


  Update tblBatches
  set Description = 'Batch 1 Continued'
  Where BatchNumber = 1 and BatchPass = 2 and StatusID = 3

  Update tblBatches
  set Description = 'Batch 2 Continued'
  Where BatchNumber = 2 and BatchPass = 2 and StatusID = 3

  Update tblBatches
  set Description = 'Batch 3 Continued'
  Where BatchNumber = 3 and BatchPass = 2 and StatusID = 3

  Update tblBatches
  set Description = 'Batch 4 Continued'
  Where BatchNumber = 4 and BatchPass = 2 and StatusID = 3


END

--Select * from tblBatches


