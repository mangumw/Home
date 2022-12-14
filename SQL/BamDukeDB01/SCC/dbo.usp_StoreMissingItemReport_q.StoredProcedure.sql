USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreMissingItemReport_q]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/16/2021
-- Description:	Difference between Scanned Items and Not Scanned Items, Missing Items
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreMissingItemReport_q] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
declare @qry varchar(8000)  
declare @BatchNumber varchar(50) 
declare @email varchar (150) 
declare @SubjectLine Varchar(200)
declare @Batch int
Declare @ReportFileName varchar (50)

SET @BatchNumber = '[sep=,' + CHAR(13) + CHAR(10) + 'BatchNumber]'  

Create table tmp_NotScanned (
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
	RetailPrice DECIMAL (18,2)
)
--declare @store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
set @email = (Select Email from tblstores where storeNumber = @Store)
set @Batch = (Select BatchNUmber from tblBatches where StatusID in (3,5) and StoreNumber = @Store)
set @SubjectLine = (Select 'Missing Item Report' + ' ' + 'Batch' + ' ' + convert( varchar (5), @Batch) + ' ' + 'Store' + ' ' + convert( varchar (5), @Store) )
set @ReportFileName =  'Batch Number' + ' ' + cast(@Batch as Varchar(10)) + ' ' + 'Missing Items'+'.csv'

insert into tmp_NotScanned (BatchNumber, 
SKU, 
Manufactures, 
Description, 
Author, 
Department, 
SubDepartment, 
SubClass, 
StoreNumber, 
ActionAllyPlacement, 
OnHand,
RetailPrice  
)

select distinct
bd.BatchNumber, 
bd.SKU, 
bd.Manufactures, 
replace(bd.Description, ',', ' ' ) as Description, 
substring(replace(replace(bd.Author, ',', ''), '.', ''), 1,15) as Author, 
replace(bd.Department, ',', '') as Deparment, 
bd.SubDepartment, 
bd.SubClass, 
bd.StoreNumber, 
replace(replace(replace(bd.ActionAllyPlacement, ',', ''),'"', ''), '-', ' ') as ActionAllyPlacement, 
bd.OnHand, bd.RetailPrice  
from tblBatchDetails bd left join
tblbatches b on bd.storenumber = b.StoreNumber and bd.BatchNumber = b.BatchNumber
where SKU not in(select e.SKU from tblScannedItems e inner join 
tblBatchDetails s on e.Storenumber=s.StoreNumber and e.SKU = s.SKU) and bd.Storenumber = @Store and b.StatusID in (3,5)



--select @qry='set nocount on;
--select BatchNumber ' + @BatchNumber + ', SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement, '' '' as Notes 
--from scc.dbo.tmp_NotScanned'  

select BatchNumber, SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement
from scc.dbo.tmp_NotScanned
   
-- Send the e-mail with the query results in attach  
--exec msdb.dbo.sp_send_dbmail 
--@profile_name = 'infausr',
--@recipients= 'kennedyl@booksamillion.com;hoskinsd@booksamillion.com;conatsert@booksamillion.com;mcconnellb@booksamillion.com',--@email,  
--@query= @qry,  
---@subject= @SubjectLine,  
--@attach_query_result_as_file = 1,  
--@query_attachment_filename = @ReportFileName,  
--@query_result_separator=',',
--@query_result_width =32767,  
--@query_result_no_padding=1 



drop table tmp_NotScanned
END


GO
