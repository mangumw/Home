USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportRollOverPassBatches]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Imports 450 Random items from as400 Batches 1-4 Single Batch
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportRollOverPassBatches] @Store int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
declare rollover_cur cursor for             
SELECT Distinct StoreNumber from [dbo].tblStores where email is not null
open rollover_cur                                        

fetch next from rollover_cur into   
@Store
while @@fetch_status = 0       
begin  

/****************************************************Looks for new stores to add the tblStores table***********************************************/
--exec usp_MigrateStores;

/*************************************************Creates Batch Number************************************************/

exec [dbo].[usp_CreateRollOverPassBatchByStore] @Store;


/*************************************************************Inserts in Batch Details table***************************************************/
--Declare @store int


insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

select distinct 
bd.BatchNumber, b.BatchPass, SKU, bd.Manufactures, bd.Description, bd.Author, bd.Department, bd.SubDepartment, bd.SubClass, 
bd.StoreNumber, bd.ActionAllyPlacement, bd.OnHand, bd.RetailPrice  
from tblBatchDetails bd left join
tblbatches b on bd.storenumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber
where SKU not in(select e.SKU from tblScannedItems e inner join tblBatchDetails s on e.Storenumber=s.StoreNumber and e.SKU = s.SKU) 
and bd.Storenumber = @Store and b.StatusID = 3 and b.BatchPass = 2


/************************************Batch Listing for RollOver Batches************************************/

exec usp_StoreBatchItemReport @Store

fetch next from rollover_cur into  
@Store
end    
close rollover_cur   
deallocate rollover_cur

END




GO
