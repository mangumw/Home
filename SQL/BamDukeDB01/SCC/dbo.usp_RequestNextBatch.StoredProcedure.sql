USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_RequestNextBatch]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/17/2021
-- Description:	Request new batch
-- 11/15/2021 Added IF statements for waitfor delay batch 5.
-- =============================================
CREATE PROCEDURE [dbo].[usp_RequestNextBatch] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--begin transaction
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

if NOT EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber in (1,2,3,4) and StatusID = 2 and 
EXISTS
  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE BatchNumber = 5 and BatchPass = 7))
begin
  
  create table #tmpBatach1234(
  Name varchar (5),
  BatchNumber varchar(2),
  StoreNumber varchar(5)
  )
  insert into #tmpBatach1234
  Select top 1
  'BATCH' as Name,
 max(b.BatchNumber)+1 as BatchNumber,
  --convert(varchar (2), isnull(( select max(isnull(BatchNumber,0))  from tblBatches ),1)) as BatchNumber,
  cast(@Store as varchar (5)) as StoreNumber
  from tblStores s inner join
  tblBatches b on s.StoreNumber = b.StoreNumber inner join
  tblScannedItems si on b.StoreNumber = si.StoreNumber
  where b.StoreNumber = @Store  and StatusID = 2


/*New code for insert*/
--declare @SCC_CMD varchar (15)
--declare @SSC_TIME datetime
--set  @SCC_CMD = (Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD from #tmpBatach1234)
--set @SSC_TIME = (Select getdate() SSC_TIME from #tmpBatach1234)


begin

insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, getdate() SSC_TIME from #tmpBatach1234
--Select @SCC_CMD as SCC_CMD, @SSC_TIME as SCC_TIME

--commit

drop table #tmpBatach1234
end

end

/*Moved to it's own stored procedure usp_ImportBatch5*/
--else
--if EXISTS (Select BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber in (1,2,3,4) and StatusID = 2 and  
--NOT EXISTS
--  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE BatchNumber = 5 and BatchPass = 7))

--begin
--  --create table #tmpBatch5(
--  --Name varchar (5),
--  --BatchNumber varchar(2),
--  --StoreNumber varchar(5)
--  --)
----  insert into #tmpBatch5
----  Select top 1
----  'BATCH' as Name,
----  convert(varchar (2), isnull(( select max(isnull(BatchNumber,1))+1  from tblBatches ),1)) as BatchNumber,
----  cast(@Store as varchar (5)) as StoreNumber
----  from tblStores s left join
----  tblBatches b on s.StoreNumber = b.StoreNumber
----  where s.StoreNumber = @Store

----insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
----Select Name + ' ' + '0' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, getdate() SSC_TIME from #tmpBatch5
--DECLARE @OPENQUERY nvarchar(4000)
--DECLARE @TSQL nvarchar(4000)
--DECLARE @LinkedServer nvarchar(4000)
--DECLARE @Store varchar(5)

--Select @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = 313))

--SET @LinkedServer = 'BKL400'

--SET @OPENQUERY = 'SELECT SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice
--FROM OPENQUERY('+ @LinkedServer + ','''

--SET @TSQL = 'select Distinct CCINUMBR as SKU, CCASNUM as Manufactures, CCIMITD1 as Description, CCIMITD2 as Author,
--CCIBDEPN as Department, CCIBSDPN as SubDepartment, CCIBCLAN as SubClass, CCISTORE as StoreNumber, CCAALOC as ActionAllyPlacement, 
--CCIBHAND as OnHand, CCRTLPRC as RetailPrice
--from piperc.cyctbtc5 where CCISTORE = ''''' + @Store + ''''''')'

--insert into tblStagingBatchDetails (
--SKU, Manufactures, [Description], Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice )
--EXEC(@OPENQUERY+@TSQL)


END
 
GO
