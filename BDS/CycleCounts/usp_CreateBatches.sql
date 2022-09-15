USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateBatches]    Script Date: 8/12/2022 1:15:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/02/2021
-- Description:	Creates Batch Numbers for tblBatches table for all Stores
-- =============================================
ALTER PROCEDURE [dbo].[usp_CreateBatches] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;


create table #tempbatches (
StoreNumber int
)

insert into #tempbatches(StoreNumber)

Select StoreNumber from Openquery (bkl400, 'Select CCISTORE as StoreNumber from MM4R4LIB.CYCTBATCH group by CCISTORE')

	--Declare @Store int  select StoreNumber from #temp
	--Set @Store =  (select StoreNumber from #temp)
	--Select * from #temp

insert into tblBatches
(BatchNumber, BatchPass, StoreNumber, StatusID)

Select Distinct
isnull(( select max(isnull(BatchNumber,1))+1  from tblBatches ),1) as BatchNumber, --+ ( ROW_NUMBER() over (order by BatchNumber) ),
'1' as BatchPass,
s.StoreNumber as StoreNumber,
'3' as StatusID
from #tempbatches s left join
tblBatches b on s.StoreNumber = b.StoreNumber
where s.StoreNumber not in (11,12,13,14,15,17,18,19,50,51,52,54,55,2115,99999,9999,986,
987,988,989,990,992,995,997,998) and s.StoreNumber !> 2000 
group by s.StoreNumber, BatchNumber

drop table #tempbatches

update tblBatches
set Description = 'Batch 1'
where BatchNumber = 1

update tblBatches
set Description = 'Batch 2'
where BatchNumber = 2

update tblBatches
set Description = 'Batch 3'
where BatchNumber = 3

update tblBatches
set Description = 'Batch 4'
where BatchNumber = 4

update tblBatches
set Description = 'Batch 5'
where BatchNumber = 5

END


