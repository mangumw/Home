USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportBatch5]    Script Date: 8/12/2022 12:45:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 12/16/2021
-- Description:	Imports Batch 5 from AS400 logical view
-- =============================================
ALTER PROCEDURE [dbo].[usp_ImportBatch5] @Store varchar(5)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
Delete from tblStagingBatchDetails where StoreNumber = @Store
exec usp_ExportNonScannedItems @Store
--if EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber in (1,2,3,4) and StatusID = 2 and  
--NOT EXISTS
--  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE BatchNumber = 5 and BatchPass = 7))
--begin
DECLARE @OPENQUERY nvarchar(4000)
DECLARE @TSQL nvarchar(4000)
DECLARE @LinkedServer nvarchar(4000)
--DECLARE @Store5 varchar(5)

Select @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

SET @LinkedServer = 'BKL400'

SET @OPENQUERY = 'SELECT SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
FROM OPENQUERY('+ @LinkedServer + ','''

SET @TSQL = 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, 
CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from mm4r4lib.cyctbtc5 where CCISTORE = ''''' + @Store + ''''''')'

insert into tblStagingBatchDetails (
SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )
EXEC(@OPENQUERY+@TSQL)

insert into tblBatchDetails (
BatchNumber, BatchPass, SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )

Select distinct b.BatchNumber, b.BatchPass, st.SKU, st.Manufactures,st.[Description], st.Author, st.Department, st.SubDepartment, 
st.SubClass, st.StoreNumber, st.ActionAllyPlacement, st.OnHand, st.RetailPrice
from tblStagingBatchDetails st left join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.SKU = bd.SKU inner join
tblBatches b on st.StoreNumber = b.StoreNumber
where b.BatchDate = dateadd(dd,datediff(dd,0,getdate()),0) and st.StoreNumber = @Store and b.StatusID = 3

exec [dbo].[usp_StoreBatchItemReport] @Store
print 'Executes Store Batch Report'


END


