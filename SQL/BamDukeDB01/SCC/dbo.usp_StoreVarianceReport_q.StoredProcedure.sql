USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreVarianceReport_q]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************
--Onhand from tblBatchdetail and actualy scanned tblScanned items
--get difference >1 add items to variance report and have recount done
--get >25$ if Onhand <> to one another add item to variance report
*******************************************/
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/16/2021
-- Description:	Difference between Scanned Items and Not Scanned Items
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreVarianceReport_q] @Store int

AS
BEGIN
	 --SET NOCOUNT ON added to prevent extra result sets from
	 --interfering with SELECT statements.
	--SET NOCOUNT ON;
--12142021 --IF EXISTS (Select * from tblBatches where Storenumber = @Store AND BatchPass = 8 and StatusID = 5)
--IF EXISTS (Select BatchNumber, BatchPass, StatusID from tblBatches where StoreNumber = @Store and BatchPass in (3,4,5,6,7) and StatusID = 5 and
--NOT EXISTS
--  (SELECT BatchNumber, BatchPass, StatusID FROM tblBatches WHERE StoreNumber = @Store and BatchNumber = 4 and BatchPass = 8))

--BEGIN


--RETURN

--END



declare @qry varchar(8000)  
declare @BatchNumber varchar(50) 
declare @email varchar (150) 
declare @SubjectLine varchar (200)
Declare @Batch int
Declare @ReportFileName varchar (50)
--Declare @store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
SET @BatchNumber = '[sep=,' + CHAR(13) + CHAR(10) + 'BatchNumber]'  

Create table tmp_VarianceItemsReport (
	[BatchNumber] [int] NOT NULL,
	[SKU] [varchar](25) NOT NULL,
	[Manufactures] [varchar](50) NULL,
	[Description] [varchar](100) NULL,
	[Author] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[SubDepartment] [varchar](100) NULL,
	[SubClass] [varchar](100) NULL,
	[StoreNumber] [int] NULL,
	[ActionAllyPlacement] [varchar] (500) NULL,
	[OnHand] [int] NULL,
	[ScannedCnt] [int] NULL,
	[Difference] int,
	RetailPrice decimal(18,2)
)
--drop table #tmpCount
 Create table #tmpCount(
StoreNumber int,
Difference int,
sku int,
BatchNumber int,
RetailPrice decimal (18,2),
OnHand int,
ScannedCnt int
)
insert into #tmpCount
Select  bd.StoreNumber, (bd.OnHand -si.ScannedCnt) as [Difference], bd.sku, bd.BatchNumber, bd.RetailPrice, bd.OnHand, si.ScannedCnt
from tblBatchDetails bd inner join
tblScannedItems si on bd.StoreNumber = si.StoreNumber and bd.BatchNumber = si.BatchNumber and bd.sku = si.SKU inner join
tblBatches b on bd.StoreNumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber and b.BatchPass = bd.BatchPass
Where bd.StoreNumber = @Store  and b.BatchPass not in (1,2,8) and b.StatusID = 5

--declare @store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
set @email = (Select Email from tblstores where storeNumber = @Store)
Set @Batch = (Select BatchNumber from tblBatches where StatusID = 5 and StoreNumber = @store)
set @SubjectLine = (Select 'Variance Report' + ' ' + 'Batch' + ' ' + convert( varchar (5), @Batch) + ' ' + 'Store' + ' ' + convert( varchar (5), @Store) )
set @ReportFileName =  'Batch Number' + ' ' + cast(@Batch as Varchar(10)) + ' ' + 'Variance Items'+'.csv'

;with cte_Qty (BatchNumber, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, Difference, RetailPrice)
as (
Select distinct si.BatchNumber, si.sku, si.Manufactures, 
replace(si.Description, ',', '') as Description, 
substring(replace(replace(si.Author, ',', ''), '.', ''), 1,15) as Author,
replace(si.Department, ',', '') as Deparment, si.SubDepartment, si.SubClass, si.StoreNumber, 
replace(si.ActionAllyPlacement, ',', '') as ActionAllyPlacement,
si.OnHand, Difference, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.[Difference] <-1) or (t.[Difference] >1) and b.StatusID = 5 and b.Description like 'Var%'
)
,
cte_Amount (BatchNumber, sku, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, Difference, RetailPrice)
as (
Select distinct si.BatchNumber, si.sku, si.Manufactures, 
replace(si.Description, ',', '') as Description, 
substring(replace(replace(si.Author, ',', ''), '.', ''), 1,15) as Author,
replace(si.Department, ',', '') as Deparment, si.SubDepartment, si.SubClass, si.StoreNumber, 
replace(si.ActionAllyPlacement, ',', '') as ActionAllyPlacement, 
si.OnHand, Difference, t.RetailPrice as RetailPrice
from tblScannedItems si inner join
#tmpCount t on si.StoreNumber = t.StoreNumber and si.sku = t.sku and si.batchnumber = t.batchnumber inner join
tblBatches b on si.StoreNumber = b.StoreNumber and si.BatchNumber = b.BatchNumber
where si.StoreNumber = @Store  and (t.RetailPrice > 25.00) and Difference!=0  --and b.StatusID = 5 and b.Description like 'Var%'
)

insert into tmp_VarianceItemsReport(BatchNumber, SKU, Manufactures, Description, Author, Department, SubDepartment, SubClass, StoreNumber, ActionAllyPlacement,  
OnHand, Difference, RetailPrice )

Select distinct q.BatchNumber, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.Difference, q.RetailPrice
from cte_qty q
union
Select distinct q.BatchNumber, q.sku, q.Manufactures, q.Description, q.Author, q.Department, q.SubDepartment, q.SubClass, 
q.StoreNumber, q.ActionAllyPlacement, q.OnHand, q.Difference, q.RetailPrice
from cte_Amount q




--select @qry='set nocount on;
--select BatchNumber ' + @BatchNumber + ', SKU, Description, Author, Department, SubDepartment, SubClass, ActionAllyPlacement, OnHand, ScannedCnt,  Difference, RetailPrice, '' '' as Notes 
--from scc.dbo.tmp_VarianceItemsReport'

select BatchNumber, SKU, Description, Author, Department, SubDepartment, SubClass, ActionAllyPlacement, OnHand, ScannedCnt,  Difference, RetailPrice
from scc.dbo.tmp_VarianceItemsReport 
   
-- Send the e-mail with the query results in attach  
--exec msdb.dbo.sp_send_dbmail 
--@profile_name = 'infausr',
--@recipients= 'kennedyl@booksamillion.com;hoskinsd@booksamillion.com;conatsert@booksamillion.com;mcconnellb@booksamillion.com',--@email,  
--@query= @qry,  
--@subject= @SubjectLine,  
--@attach_query_result_as_file = 1,  
--@query_attachment_filename = @ReportFileName,  
--@query_result_separator=',',
--@query_result_width =32767,  
--@query_result_no_padding=1 



/********************************************Close variance batch when items at zero*************************************/
/*
declare @SkuCount int
Set @SkuCount = (select count(sku) from tmp_VarianceItems)
update tblBatches
set StatusID = 2
where Storenumber = @Store and @SkuCount = 0 and Description like 'Vari%'
*/

/**********************************************************Removes Items from tblScannedItems no longer needed for Variance************************************************/
Delete si
--Select si.*
from tblBatches b inner join
tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass 
where b.StoreNumber = @Store and b.StatusID = 5 and b.BatchPass in (3,4,5,6,7)
Print 'Removes Scanned Items not needed @End of Variance Report Proc for Pass 3,4,5,6,7'


--MOVED TO NEW PROC VARIANCE BATCH 4 FOR PASS 8 ONLY TO AVOID 2 VARIANCE REPORTS EMAILING 10/19/2021 821AM
----Added 10/18/2021 @700Pm to delete only items not in variance
--Delete si
----Select si.*
--from tblBatches b inner join
--tblScannedItems si on b.StoreNumber = si.StoreNumber and b.BatchNumber = si.BatchNumber and b.BatchPass = si.BatchPass 
--where b.StoreNumber = @Store and b.StatusID = 5 and b.BatchPass = 8 and OnHand = ScannedCnt
--Print 'Removes Scanned Items not needed @End of Variance Report Proc for Pass 8'

----Added 10/19/2021 to remove deuplicate that are no longer needed.
--DELETE 
----Select * 
--FROM tblScannedItems WHERE ScanID NOT IN (SELECT max(ScanID) FROM tblScannedItems GROUP BY SKU) and  BatchPass = 8 and OnHand <> ScannedCnt 
 --Max for Oldest ScanID 
 --Min for Latest ScanID

--if exists (Select BatchNumber, 
--  BatchPass, StoreNumber, StatusID from tblBatches
--  where Batchpass = 6 and BatchNumber = 4 and StatusID = 2 and Storenumber = @Store
--  )
--  begin
--  insert into tblBatches( 
--  BatchNumber, 
--  BatchPass, 
--  StoreNumber,
--  Description, 
--  StatusID 
--  )
--  Select BatchNumber, 
--  BatchPass, 
--  StoreNumber,
--  'Day 5' as Description, 
--  StatusID 
--  from tblBatches
--  where BatchNumber = 5
--  end

--Select * from tmp_VarianceItems
drop table tmp_VarianceItemsReport
Drop table #tmpCount
END


GO
