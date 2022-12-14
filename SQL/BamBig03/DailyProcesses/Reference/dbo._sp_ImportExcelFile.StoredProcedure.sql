USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[_sp_ImportExcelFile]    Script Date: 8/19/2022 3:46:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[_sp_ImportExcelFile]             
            (@Source varchar(1000)
            , @SourceSheet varchar (100)
            , @DestinationTable varchar (100))
as 

declare @retval int
EXEC master..xp_fileexist @Source, @retval output -- check if file exists
 
if @retval = 0
            begin
                        print 'file does not exist.'
                        return
            end
 
if @SourceSheet is null or @SourceSheet = ''
            set @SourceSheet = '[void_sku_list]' -- assume that the Sheet name on excel file is the default name
else
            set @SourceSheet = '[' + ltrim(rtrim(@SourceSheet)) + '$]'

if @DestinationTable is null or @DestinationTable = ''
            set @DestinationTable = substring(@SourceSheet, 2, len(@SourceSheet) - 3) + convert(varchar, getdate(), 126)

exec('select * into #temp from openrowset(''Microsoft.Jet.OLEDB.4.0'', ''Excel 8.0;HDR=YES;Database=' + @Source + ''', ' + @SourceSheet + ')')
GO
