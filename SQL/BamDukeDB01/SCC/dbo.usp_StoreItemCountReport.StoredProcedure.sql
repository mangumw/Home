USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_StoreItemCountReport]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/17/2021
-- Description:	Store Item Count
-- =============================================
CREATE PROCEDURE [dbo].[usp_StoreItemCountReport] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @qry varchar(8000)  
declare @ItemCount varchar(50) 
declare @email varchar (150)
declare @SubjectLine varchar (200)
declare @Batch int
--declare emailList CURSOR FOR
--Select email from tblstores where email is not null
--open emaillist
--fetch next from emaillist into @email
--while @@FETCH_STATUS = 0
--begin
--declare @Store int 


SET @ItemCount = '[sep=,' + CHAR(13) + CHAR(10) + 'Total Item Count]'  


set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
set @email = (Select Email from tblstores where storeNumber = @Store)
set @Batch = (Select BatchNUmber from tblBatches where StatusID = 3 and StoreNumber = @Store)
set @SubjectLine = (Select 'Total Items Counted' + + ' ' + 'Batch' + ' ' + convert( varchar (5), @Batch) + ' ' + 'Store' + ' ' + convert( varchar (5), @Store) )

Create table tmp_Count (
[Total Item Count] varchar (4)
)
insert into tmp_Count
Select count(*) as [Total Item Count] from tblScannedItems where StoreNumber = @Store



select @qry='set nocount on;
select [Total Item Count] ' + @ItemCount + ', '' '' as Notes 
from scc.dbo.tmp_Count'  
   
-- Send the e-mail with the query results in attach  
exec msdb.dbo.sp_send_dbmail 
@profile_name = 'infausr',
@recipients= 'kennedyl@booksamillion.com',--@email,  
@query= @qry,  
@subject= @SubjectLine,
@body= 'If item count is below 1800 please request items added to Batch 4',  
@attach_query_result_as_file = 1,  
@query_attachment_filename = 'TotalItemCount.csv',  
@query_result_separator=',',
@query_result_width =32767,  
@query_result_no_padding=1 


drop table tmp_Count

--fetch next from emaillist into @email
--end
--close emaillist
--deallocate emaillist
END

GO
