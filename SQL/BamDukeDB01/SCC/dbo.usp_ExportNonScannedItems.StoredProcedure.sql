USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ExportNonScannedItems]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 01/10/2022
-- Description:	Moves items that were never scanned to tblHoldScannedItems
-- =============================================
CREATE PROCEDURE [dbo].[usp_ExportNonScannedItems] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

--delete from tblHoldScannedItems where storenumber =  @Store

insert into tblHoldScannedItems (
BatchDetailID, BatchNumber,BatchPass,SKU,Manufactures,Description,Author,Department,SubDepartment,
SubClass,StoreNumber,ActionAllyPlacement,OnHand,ScannedCnt,RetailPrice
)

Select b.BatchDetailID, b.BatchNumber,b.BatchPass,b.SKU,b.Manufactures,b.Description,b.Author,
b.Department,b.SubDepartment,b.SubClass,b.StoreNumber,b.ActionAllyPlacement,b.OnHand,NULL as ScannedCnt,b.RetailPrice
from tblBatchDetails b left join
tblHoldScannedItems h on b.BatchDetailID = h.BatchDetailID
where NOT EXISTS (Select BatchNumber,BatchPass,SKU
from tblScannedItems s where b.BatchNumber = s.BatchNumber and b.SKU = s.SKU) --do not put batchpass in the join, it will bring items that were in the first passes and vairance passes.
and b.BatchPass <> 9 and b.StoreNumber = @Store and h.BatchDetailID is null 

--and b.BatchNumber not in (1,4)  and b.StoreNumber = @Store and h.BatchDetailID is null 
--ORG Where STMT -- and b.BatchPass <> 9 and b.StoreNumber = @Store and h.BatchDetailID is null 

--Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,
--Department,SubDepartment,SubClass,StoreNumber,ActionAllyPlacement,OnHand,NULL as ScannedCnt,RetailPrice
--from tblBatchDetails b
--where NOT EXISTS (Select BatchNumber,BatchPass,SKU
--from tblScannedItems s where b.BatchNumber = s.BatchNumber and b.BatchPass = s.BatchPass and b.sku = s.sku)
--and b.StoreNumber = @Store and BatchPass in (1,2)

--union

--Select BatchNumber,BatchPass,SKU,Manufactures,Description,Author,
--Department,SubDepartment,SubClass,StoreNumber,ActionAllyPlacement,OnHand,NULL as ScannedCnt,RetailPrice
--from tblBatchDetails b
--where NOT EXISTS (Select BatchNumber,BatchPass,SKU
--from tblScannedItems s where b.BatchNumber = s.BatchNumber and b.BatchPass = s.BatchPass and b.sku = s.sku)
--and b.StoreNumber = @Store and BatchPass in (3,4,5,6,7,8)

END



--Select b.BatchNumber,b.BatchPass,b.SKU,b.Manufactures,b.Description,b.Author,
--b.Department,b.SubDepartment,b.SubClass,b.StoreNumber,b.ActionAllyPlacement,b.OnHand,NULL as ScannedCnt,b.RetailPrice
--from tblBatchDetails b left join
--tblScanneditems s on b.StoreNumber = s.StoreNumber and b.BatchNumber = s.BatchNumber and b.sku = s.sku and s.BatchPass = b.BatchPass
--where b.Batchpass in (3,4,5,6,8) and b.Storenumber = @Store

--Select max(batchpass) as BatchPass, BatchNumber, SKU, Manufactures, Description, Author, Department,
--SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, NULL, RetailPrice
--from tblBatchDetails 
--where sku = 8772152
--group by BatchNumber,SKU,Manufactures,Description,Author,Department,SubDepartment,
--SubClass,StoreNumber,ActionAllyPlacement,OnHand,RetailPrice

GO
