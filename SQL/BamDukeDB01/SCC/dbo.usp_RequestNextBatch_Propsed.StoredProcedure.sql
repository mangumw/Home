USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_RequestNextBatch_Propsed]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 08/11/2022
-- Description:	to replace usp_RequestNextBatch with a perm control table for easier troubleshooting.
-- =============================================
CREATE PROCEDURE [dbo].[usp_RequestNextBatch_Propsed] @Store int

AS
BEGIN

	SET NOCOUNT ON;
	set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = 653))

if NOT EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber in (1,2,3,4) and StatusID = 2 and 
EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE BatchNumber = 5 and BatchPass = 7))
begin  

  insert into tblBatchServerCommands
  Select top 1
  'BATCH' as Name,
 max(b.BatchNumber)+1 as BatchNumber,
  cast(@Store as varchar (5)) as StoreNumber,
  getdate() as SSC_TIME
  from tblStores s inner join
  tblBatches b on s.StoreNumber = b.StoreNumber inner join
  tblScannedItems si on b.StoreNumber = si.StoreNumber
  where b.StoreNumber = @Store  and StatusID = 2
end


begin
insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, MAX(cast(SSC_TIME as Date)) as SSC_TIME from tblBatchServerCommands group by name, BatchNumber, StoreNumber

end

END

GO
