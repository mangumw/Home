USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportScannedDataReporting]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/29/2021
-- Description:	Inserts into AS400 table for Qlik Sense to grab for reporting
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportScannedDataReporting] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
--declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

--declare insert_cur cursor for             
--SELECT Distinct StoreNumber from [dbo].tblBatches
--open insert_cur                                        

--fetch next from insert_cur into   
--@Store
--while @@fetch_status = 0       
--begin   

insert openquery (bkl400, 'Select BatchNumb, BatchPass, SKU, Manfacture, desc, Author, Department, SubDepart, subClass,
StoreNumb, Action, OnHand, ScannedCnt, Retail, DateCreate, CreatedBy, ItemPOsted from MM4R4LIB.TBLSCNITEM')

Select si.BatchNumber as BatchNumb, si.BatchPass, si.SKU, si.Manufactures as Manufacture, si.Description as [Desc], 
si.Author, si.Department, si.SubDepartment as SubDepart, si.SubClass, si.StoreNumber as StoreNumb,
si.ActionAllyPlacement as [Action], si.OnHand, si.ScannedCnt, si.RetailPrice as Retail, si.DateCreated, si.CreatedBy, si.ItemPosted
from tblScannedItems si inner join
tblBatches b on b.BatchNumber = si.BatchNumber and b.StoreNumber = si.StoreNumber and b.BatchPass = si.BatchPass
where si.Storenumber = @Store and si.ItemPosted = 1 and b.StatusID = 2


--fetch next from insert_cur into  
--@Store
--end    
--close insert_cur   
--deallocate insert_cur

END


GO
