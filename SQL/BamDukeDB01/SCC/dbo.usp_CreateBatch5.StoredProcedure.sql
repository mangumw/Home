USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateBatch5]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateBatch5] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
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
END

GO
