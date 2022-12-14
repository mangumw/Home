USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[up_bn_storage_map]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_bn_storage_map]
    @db sysname,
    @filename sysname
AS
declare @version varchar(4)
BEGIN
set nocount on
 
select @version = substring(@@version,23,4)
 
/*
*****************************************************************************
 * create worktable for extent information
******************************************************************************
*/
if @version = '7.00'
    create table #extent_info7
    (fileid int NULL,
     pageid int NULL,
     pgalloc int NULL,
     extent_size int NULL,
     table_id int NULL,
     index_id int NULL,
     pfs_bytes varbinary(1000) NULL,
     avg_used int NULL)
else if @version = '2000'
        create table #extent_info8
        (fileid int NULL,
         pageid int NULL,
         pgalloc int NULL,
         extent_size int NULL,
         table_id int NULL,
         index_id int NULL,
         pfs_bytes varbinary(1000) NULL)
     else
         create table #extent_info9
        (fileid int NULL,
         pageid int NULL,
         pgalloc int NULL,
         extent_size int NULL,
         table_id int NULL,
         index_id int NULL,
         partition_number int NULL,
         iam_chain_type varchar(50) NULL,
         pfs_bytes varbinary(1000) NULL)
 
/*
*****************************************************************************
 * get database extent map data
******************************************************************************
*/
 
if @version = '7.00'
    insert into #extent_info7 
    exec ('dbcc extentinfo ([' + @db + ']) WITH NO_INFOMSGS'  )
else if @version = '2000'
    insert into #extent_info8 
    exec ('dbcc extentinfo ([' + @db + ']) WITH NO_INFOMSGS'  )
else
    insert into #extent_info9 
    exec ('dbcc extentinfo ([' + @db + ']) WITH NO_INFOMSGS'  )
/*
*****************************************************************************
 * present database map in extent order
******************************************************************************
*/
 
if @version = '7.00'
    exec ('use [' + @db + '] 
    select 
        fileid,
        pageid,
        map_block = pageid / 8,extent_number = (pageid / 8) * 8,
        pgalloc,
        extent_size,
        owner = user_name(uid),
        table_name = object_name(table_id), 
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX''
        when 255 then ''TEXT'' else ''INDEX'' end,
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end,
        table_id,
        index_id 
    from 
        #extent_info7 a, 
        sysobjects b, 
        sysindexes c 
    where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        c.name not like ''_WA%'' and 
        file_name(fileid) = ''' + @filename + ''' order by 1,2')
else if @version = '2000'
    exec ('use [' + @db + '] 
    select 
        fileid,
        pageid,
        map_block = pageid / 8,extent_number = (pageid / 8) * 8,
        pgalloc,
        extent_size,
        owner = user_name(uid),
        table_name = object_name(table_id), 
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX'' 
        when 255 then ''TEXT'' else ''INDEX'' end,
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end, 
        table_id,
        index_id 
     from 
        #extent_info8 a, 
        sysobjects b, 
        sysindexes c 
     where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        c.name not like ''_WA%'' and 
        file_name(fileid) = ''' + @filename + ''' order by 1,2')
else
    exec ('use [' + @db + '] 
    select 
        fileid,
        pageid,
        map_block = pageid / 8,extent_number = (pageid / 8) * 8,
        pgalloc,
        extent_size,
        owner = user_name(uid),
        table_name = object_name(table_id), 
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX'' 
        when 255 then ''TEXT'' else ''INDEX'' end,
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end, 
        table_id,
        index_id 
    from 
        #extent_info9 a, 
        sysobjects b, 
        sysindexes c 
    where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        (c.name NOT LIKE ''_WA%'' or c.name is null) 
        and file_name(fileid) = ''' + @filename + ''' order by 1,2')

/*
*****************************************************************************
 * present grid of map info
******************************************************************************
*/
 
if @version = '7.00'
    exec('use [' + @db + '] 
    select 
        owner = user_name(uid),
        table_name = object_name(table_id),
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX'' 
        when 255 then ''TEXT'' else ''INDEX'' end, 
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end,
        pages_used = sum(convert(decimal(35,2),pgalloc)), 
        pages_allocated = sum(convert(decimal(35,2),extent_size)), 
        in_extents = count(distinct (pageid / 8) * 8), 
        table_id,
        index_id 
    from 
        #extent_info7 a, 
        sysobjects b, 
        sysindexes c 
    where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        c.name not like ''_WA%'' and 
        file_name(fileid) = ''' + @filename + ''' 
    group by 
        b.uid,
        object_name(table_id),
        index_id,
        c.name,
        table_id 
    order by 
        1,2,9')
else if @version = '2000'
    exec('use [' + @db + '] select 
        owner = user_name(uid),
        table_name = object_name(table_id),
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX'' 
        when 255 then ''TEXT'' else ''INDEX'' end, 
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end,
        pages_used = sum(convert(decimal(35,2),pgalloc)), 
        pages_allocated = sum(convert(decimal(35,2),extent_size)), 
        in_extents = count(distinct (pageid / 8) * 8), 
        table_id,
        index_id 
    from 
        #extent_info8 a, 
        sysobjects b, 
        sysindexes c 
    where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        c.name not like ''_WA%'' and 
        file_name(fileid) = ''' + @filename + ''' 
    group by 
        b.uid,
        object_name(table_id),
        index_id,
        c.name,
        table_id 
    order by 
        1,2,9')
else
    exec('use [' + @db + '] 
    select 
        owner = user_name(uid),
        table_name = object_name(table_id),
        object_type = case index_id when 0 then ''TABLE'' 

        when 1 then ''CLUSTERED TABLE/INDEX'' 
        when 255 then ''TEXT'' else ''INDEX'' end, 
        index_name = case index_id when 0 then ''N/A'' when 255 then ''N/A'' 

        else c.name end,
        pages_used = sum(convert(decimal(35,2),pgalloc)), 
        pages_allocated = sum(convert(decimal(35,2),extent_size)), 
        in_extents = count(distinct (pageid / 8) * 8), 
        table_id,index_id 
    from 
        #extent_info9 a, 
        sysobjects b, 
        sysindexes c 
    where 
        a.table_id = b.id and 
        a.table_id = c.id and 
        a.index_id = c.indid and 
        (c.name NOT LIKE ''_WA%'' or c.name is null) and 
        file_name(fileid) = ''' + @filename + ''' 
    group by 
        b.uid,
        object_name(table_id),
        index_id,
        c.name,
        table_id 
    order by 
        1,2,9')
 
/*
*****************************************************************************
 * present extent/space overview
******************************************************************************
*/
 
if @version = '7.00'
    exec ('use [' + @db + '] 
    select 
        table_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info7 
            where index_id in (0,1) and file_name(fileid) = ''' + @filename + '''),
        index_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info7 
            where index_id > 1 and index_id < 255 and
            file_name(fileid) = ''' + @filename + '''),
        text_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info7 
            where index_id = 255 and file_name(fileid) = ''' + @filename + ''')')
else if @version = '2000'
    exec ('use [' + @db + '] select 
        table_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info8 
            where index_id in (0,1) and file_name(fileid) = ''' + @filename + '''),
        index_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info8 
            where index_id > 1 and index_id < 255 and 
            file_name(fileid) = ''' + @filename + '''),
        text_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info8 
            where index_id = 255 and file_name(fileid) = ''' + @filename + ''')')
else
    exec ('use [' + @db + '] select 
        table_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info9 
            where index_id in (0,1) and file_name(fileid) = ''' + @filename + '''),
        index_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info9 
            where index_id > 1 and index_id < 255 and 
            file_name(fileid) = ''' + @filename + '''),
        text_extents = (select count(distinct (pageid / 8) * 8) 
            from #extent_info9 
            where index_id = 255 and file_name(fileid) = ''' + @filename + ''')')

    
/* clean up */
 
if @version = '7.00'
    drop table #extent_info7
else if @version = '2000' 
    drop table #extent_info8
else
    drop table #extent_info9
    
  RETURN(0)
END
GO
