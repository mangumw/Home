USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreBatchItemReport_q]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/15/2021
-- Description: Detail Report for Batched Items for Store to Scan
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreBatchItemReport_q] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
declare @qry varchar(8000)  
declare @BatchNumber varchar(50)  
declare @email varchar (150)
declare @SubjectLine varchar (200)
Declare @Batch int
Declare @ReportFileName varchar (50)
--Declare @Str varchar(1) = ' '' ' + 'Select upc from tblBatchDetails'
--Declare @Store int
--Set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
-- Create the column name with the instrucation in a variable  
SET @BatchNumber = '[sep=,' + CHAR(13) + CHAR(10) + 'BatchNumber]'  

Create table tmp_BatchDetails (
	[BatchNumber] [int] NOT NULL,
	[SKU] [varchar](25) NOT NULL,
	[Manufactures] [varchar](50) NULL,
	[Description] [varchar](100) NULL,
	[Author] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[SubDepartment] [varchar](100) NULL,
	[SubClass] [varchar](100) NULL,
	[StoreNumber] [int] NULL,
	[ActionAllyPlacement] [varchar](500)  NULL,
	[OnHand] [int] NULL,
	RetailPrice decimal (18,2)
)
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
Set @Batch = (Select BatchNumber from tblBatches where StatusID = 3 and StoreNumber = @Store)
set @email = (Select Email from tblstores where storeNumber = @Store)
set @SubjectLine = (Select 'Batch Item Listing' + ' ' + 'Batch' + ' ' + convert( varchar (5), @Batch) + ' ' + 'Store' + ' ' + convert( varchar (5), @Store) )
set @ReportFileName =  'Batch Number' + ' ' + cast(@Batch as Varchar(10)) + ' ' + 'Batched Items'+'.csv'

insert into tmp_BatchDetails
Select bd.BatchNumber, bd.SKU, bd.Manufactures, replace(bd.Description, ',', ' ' ) as Description, 
substring(replace(replace(bd.Author, ',', ''), '.', ''), 1,15) as Author,  
replace(bd.Department, ',', '') as Deparment, 
bd.SubDepartment, bd.SubClass, bd.StoreNumber, replace(bd.ActionAllyPlacement, ',', '') as ActionAllyPlacement, bd.OnHand, RetailPrice
from tblBatchDetails bd inner join
tblBatches b on bd.storenumber = b.storenumber and bd.BatchNumber = b.BatchNumber and bd.BatchPass = b.BatchPass
where bd.Storenumber = @Store and b.BatchNumber not in (5) and b.StatusID = 3


--Select * from tmp_BatchDetails where sku = '3209261'


--select @qry='set nocount on;
--select BatchNumber ' + @BatchNumber + ',SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement, '' '' as Notes 
--from scc.dbo.tmp_BatchDetails'  

select BatchNumber ,SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement 
from scc.dbo.tmp_BatchDetails 

   
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



drop table tmp_BatchDetails

END


GO
