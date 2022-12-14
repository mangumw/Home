USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateSupplementBatch4ByStore]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/15/2021
-- Description:	Bacth 4 Batch Creation Supplement
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateSupplementBatch4ByStore] @Store int 

AS
--THIS DOES NOT CREATE VARIACNE BATCHES!!!
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

IF NOT EXISTS (Select BatchPass from tblBatches where BatchPass in (7,9) and StatusID = 2 and Storenumber = @Store)

BEGIN

insert into tblBatches values (4,9,@Store, 'Supplemental Batch', getdate (),3)
print 'insert 4 9 Supplemental Batch'

RETURN
 
END




GO
