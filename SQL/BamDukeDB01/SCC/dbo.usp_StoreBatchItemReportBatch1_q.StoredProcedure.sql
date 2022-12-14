USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreBatchItemReportBatch1_q]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/27/2021
-- Description:	Emails Bacth Item Listing to the stores for Bacth One
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreBatchItemReportBatch1_q] @Store int

AS
declare @qry varchar(8000)  
declare @BatchNumber varchar(50)  
declare @email varchar (150)
--Declare @Store int
declare @body varchar (50) 
declare @SubjectLine varchar (200) 
declare @Batch int
Declare @ReportFileName varchar (50)

--declare test_cur cursor for             
--SELECT StoreNumber, EmailAddress from [dbo].tblEmails
--open test_cur                                        

--fetch next from test_cur into   
--@Store, @Email
--while @@fetch_status = 0       
--begin                                    

set @Body = 'Batch Item Listing'
set @Store = (select StoreNumber = @Store from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
Set @Batch = (Select BatchNumber from tblBatches where StatusID = 3 and StoreNumber = @Store)
set @body = (SELECT body = @body from [dbo].tblEmails where EmailAddress = @email and StoreNumber = @Store)
set @SubjectLine = (Select 'Batch Item Listing' + ' ' + 'Batch 1' + ' '+ 'Store' + ' ' + convert( varchar (5), @Store) )
set @ReportFileName =  'Batch Number' + ' ' + cast(@Batch as Varchar(10)) + ' ' + 'Batched Items'+'.csv'

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
	[ActionAllyPlacement] [varchar] (500) NULL,
	[OnHand] [int] NULL,
	RetailPrice Decimal (18,2)
)


insert into tmp_BatchDetails
Select BatchNumber, SKU, Manufactures, replace(Description, ',', ' ' ) as Description, 
substring(replace(replace(Author, ',', ''), '.', ''), 1,15) as Author, Department, 
SubDepartment, SubClass, StoreNumber, ActionAllyPlacement, OnHand, RetailPrice 
from tblBatchDetails where Storenumber = @Store and BatchNumber = 1


--select @qry='set nocount on;
--select BatchNumber ' + @BatchNumber + ',SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement, '' '' as Notes 
--from scc.dbo.tmp_BatchDetails'  
 

SET NOCOUNT ON

select BatchNumber, SKU, Description, Author, Department, SubDepartment, SubClass, RetailPrice, ActionAllyPlacement 
from scc.dbo.tmp_BatchDetails;
   
   
--exec @qry;

--exec msdb.dbo.sp_send_dbmail 
--@profile_name = 'infausr',
--@recipients= 'kennedyl@booksamillion.com;hoskinsd@booksamillion.com;conatsert@booksamillion.com;mcconnellb@booksamillion.com',--@email, 
--@query= @qry,  
--@subject= @SubjectLine,
--@body = @body,  
--@attach_query_result_as_file = 1,  
--@query_attachment_filename = @ReportFileName,  
--@query_result_separator=',',
--@query_result_width =32767,  
--@query_result_no_padding=1 


drop table tmp_BatchDetails

--fetch next from test_cur into  
--@Store, @Email
--end    
--close test_cur   
--deallocate test_cur


GO
