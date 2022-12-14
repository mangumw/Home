USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportAddsToBatch4]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 12/30/2021
-- Description:	New Batch Supp Process
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportAddsToBatch4] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

--exec [dbo].[usp_CreateSupplementBatch4ByStore] @Store;

--exec usp_ExportNonScannedItems @Store;
truncate table tblCountItems
/*************************************Pulls Limit from as400**************************************/
create table #tmpStoreCnt (
StoreNumber int,
Date Date,
Count1 int,
Count2 int,
Count3 int,
Count4 int,
Count4Add int,
Count5 int
)
insert into #tmpStoreCnt
Select StoreNumber, Date, Count1, Count2, Count3, Count4, Count4Add, Count5 
from openquery (bkl400, 'Select CSISTORE as StoreNumber, DATE( TIMESTAMP_FORMAT(cast(CSIDYDTE as varchar(8)), ''YYYYMMDD''))  as Date, CSIDYCNT1 as Count1, CSIDYCNT2 as Count2, CSIDYCNT3 as Count3, CSIDYCNT4 as Count4,
CSIDYCNT99 as Count4Add, CSIDYCNT5 as Count5 
from MM4R4LIB.cyctstore')

insert into tblCountItems
Select * from #tmpStoreCnt
drop table #tmpStoreCnt
print 'Insert into tblCount table'

/*************************************************************Moves items from tblHoldScannedItems to tblBatchDetails**********************************************************/
insert into tblBatchDetails(
BatchNumber, BatchPass, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass,
StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
)

Select distinct 4 as BatchNumber, 9 as BatchPass, h1.SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass,
StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
from tblHoldScannedItems h1,
(select BatchNumber, Sku, max(BatchPass) as BatchPass from tblHoldScannedItems where BatchPass <> 9
group by BatchNumber, SKU) h2
where Storenumber = @Store
print'Moves items from tblHoldScannedItems to tblBatchDetails'

END


--Select max(BatchPass) as Batchpass, BatchNumber, SKU, Manufactures, Description,SubDepartment, Department, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice, 
--ltrim(rtrim(replace(Author, ',',''))) as Author
--from tblHoldScannedItems group by BatchNumber, SKU,
--Manufactures,Description,SubDepartment, Department, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice, Author

--Select * from tblScannedItems
GO
