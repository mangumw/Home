USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreOnHandForNightlyProcess]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 10/08/2021
-- Description:	Updates OnHands for Batch pass 1 and 2
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreOnHandForNightlyProcess] 

AS
BEGIN
Declare @Store int
declare onhand_cur cursor for             
SELECT Distinct StoreNumber from [dbo].tblBatches where StatusID = 3
open onhand_cur                                        

fetch next from onhand_cur into   
@Store
while @@fetch_status = 0       
begin                                    

set @Store = (select StoreNumber = @Store from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

/************************************************Insert record into as400 to get update OnHands, this not the query but an example********************************************/
  create table #tmp2(
  Name varchar (10),
  BatchNumber varchar(2),
  StoreNumber varchar(5)
  )
  insert into #tmp2
  Select top 1
  'ONHAND' as Name,
  convert(varchar (2), isnull(( select max(isnull(BatchNumber,1))+1  from tblBatches ),1)) as BatchNumber,
  cast(@Store as varchar (5)) as StoreNumber
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store

insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, getdate() SSC_TIME from #tmp2

/*********************************************************put into staging table to insert records from as400*****************************************************/
truncate table tblStagingBatchDetails;

insert into tblStagingBatchDetails (
SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, OnHand, RetailPrice )

select SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, OnHand, RetailPrice
from openquery (bkl400, 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, 
CCIBHAND as OnHand, CCRTLPRC as RetailPrice
from MM4R4LIB.CYCTBATCH') where StoreNumber = @Store --Set Variable to look at store number in stores and Batches table where statusid = 3

/************************************************************Create Update OnHand from temp table items from the as400******************************************/
update bd
set bd.OnHand = st.OnHand
from tblStagingBatchDetails st inner join
tblBatchDetails bd on st.StoreNumber = bd.StoreNumber and st.sku = bd.sku inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and b.BatchNumber = bd.BatchNumber and b.BatchPass = bd.BatchPass 
where bd.StoreNumber = @Store and bd.BatchPass in (1,2) and b.StatusID = 3

drop table #tmp2
fetch next from onhand_cur into  
@Store
end    
close onhand_cur   
deallocate onhand_cur
end

GO
