USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportBatches]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Imports 450 Random items from as400 Batches 1-4
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportBatches] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
--declare Store_Cur cursor for             
--SELECT Distinct StoreNumber from [dbo].tblStores
--open Store_Cur                                        

--fetch next from Store_Cur into   
--@Store
--while @@fetch_status = 0       
--begin   
/***********************************************Check if Single Batch is closed and if not do not Continue*************************************************/

IF EXISTS (Select * from tblBatches where BatchPass in (1,2) and StatusID = 3)

BEGIN


RETURN

END
	
/****************************************************Looks for new stores to add the tblStores table***********************************************/
exec usp_MigrateStores;

/*************************************************Creates Batch Number************************************************/

exec dbo.usp_CreateBatches;

/**************************************************Inserts/Scrubs all data************************************************************/
truncate table tblStagingBatchDetails;

insert into tblStagingBatchDetails (
SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

select SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
from openquery (bkl400, 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, 
CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from MM4R4LIB.CYCTBATCH')



--Truncate table tblStagingBatchDetails
--Select * from tblStagingBatchDetails
/*************************************************************Inserts in Batch Details table***************************************************/
insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct b.BatchNumber, b.BatchPass, st.SKU, st.Manufactures,st.Description, st.Author, st.Department, st.SubDepartment, 
st.SubClass, st.StoreNumber, st.ActionAllyPlacement, st.OnHand, st.RetailPrice
from tblStagingBatchDetails st left join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.SKU = bd.SKU inner join
tblBatches b on st.StoreNumber = b.StoreNumber
where b.BatchDate = dateadd(dd,datediff(dd,0,getdate()),0)


/***********************************************************Executes Batch 1 on BatchItem Report**************************************************/
exec dbo.usp_StoreBatchItemReportBatch1

--fetch next from Store_Cur into  
--@Store
--end    
--close Store_Cur   
--deallocate Store_Cur
END


GO
