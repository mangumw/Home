USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Get_permission]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Get_permission] 
AS 
    DECLARE @db_name  VARCHAR(200), 
            @sql_text VARCHAR(max) 

    SET @sql_text='Create table ##db_name (user_name varchar(max),' 

    DECLARE db_cursor CURSOR FOR 
      SELECT name 
      FROM   sys.databases 

    OPEN db_cursor 

    FETCH next FROM db_cursor INTO @db_name 

    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          SET @sql_text=@sql_text + @db_name + ' varchar(max),' 

          FETCH next FROM db_cursor INTO @db_name 
      END 

    CLOSE db_cursor 

    SET @sql_text=@sql_text + 'Server_perm varchar(max))' 

    EXEC (@sql_text) 

    DEALLOCATE db_cursor 

    DECLARE @RoleName VARCHAR(50) 
    DECLARE @UserName VARCHAR(50) 
    DECLARE @CMD VARCHAR(1000) 

    CREATE TABLE #permission 
      ( 
         user_name    VARCHAR(50), 
         databasename VARCHAR(50), 
         role         VARCHAR(50) 
      ) 

    DECLARE longspcur CURSOR FOR 
      SELECT name 
      FROM   sys.server_principals 
      WHERE  type IN ( 'S', 'U', 'G' ) 
             AND principal_id > 4 
             AND name NOT LIKE '##%' 
             AND name <> 'NT AUTHORITY\SYSTEM' 
             AND name <> 'ONDEMAND\Administrator' 
             AND name NOT LIKE 'steel%' 

    OPEN longspcur 

    FETCH next FROM longspcur INTO @UserName 

    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          CREATE TABLE #userroles_kk 
            ( 
               databasename VARCHAR(50), 
               role         VARCHAR(50) 
            ) 

          CREATE TABLE #rolemember_kk 
            ( 
               dbrole     VARCHAR(100), 
               membername VARCHAR(100), 
               membersid  VARBINARY(2048) 
            ) 

          SET @CMD = 'use ? truncate table #RoleMember_kk insert into #RoleMember_kk exec sp_helprolemember  insert into #UserRoles_kk (DatabaseName, Role) select db_name(), dbRole from #RoleMember_kk where MemberName = ''' + @UserName + '''' 

          EXEC Sp_msforeachdb 
            @CMD 

          INSERT INTO #permission 
          SELECT @UserName 'user', 
                 b.name, 
                 u.role 
          FROM   sys.sysdatabases b 
                 LEFT OUTER JOIN #userroles_kk u 
                              ON u.databasename = b.name --and u.Role='db_owner' 
          ORDER  BY 1 

          DROP TABLE #userroles_kk; 

          DROP TABLE #rolemember_kk; 

          FETCH next FROM longspcur INTO @UserName 
      END 

    CLOSE longspcur 

    DEALLOCATE longspcur 

    TRUNCATE TABLE ##db_name 

    DECLARE @d1 VARCHAR(max), 
            @d2 VARCHAR(max), 
            @d3 VARCHAR(max), 
            @ss VARCHAR(max) 
    DECLARE perm_cur CURSOR FOR 
      SELECT * 
      FROM   #permission 
      ORDER  BY 2 DESC 

    OPEN perm_cur 

    FETCH next FROM perm_cur INTO @d1, @d2, @d3 

    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          IF NOT EXISTS(SELECT 1 
                        FROM   ##db_name 
                        WHERE  user_name = @d1) 
            BEGIN 
                SET @ss='insert into ##db_name(user_name) values (''' 
                        + @d1 + ''')' 

                EXEC (@ss) 

                SET @ss='update ##db_name set ' + @d2 + '=''' + @d3 
                        + ''' where user_name=''' + @d1 + '''' 

                EXEC (@ss) 
            END 
          ELSE 
            BEGIN 
                DECLARE @var            NVARCHAR(max), 
                        @ParmDefinition NVARCHAR(max), 
                        @var1           NVARCHAR(max) 

                SET @var = N'select @var1=' + @d2 
                           + ' from ##db_name where USER_NAME=''' + @d1 
                           + ''''; 
                SET @ParmDefinition = N'@var1 nvarchar(300) OUTPUT'; 

                EXECUTE Sp_executesql 
                  @var, 
                  @ParmDefinition, 
                  @var1=@var1 output; 

                SET @var1=Isnull(@var1, ' ') 
                SET @var= '  update ##db_name set ' + @d2 + '=''' + @var1 + ' ' 
                          + @d3 + ''' where user_name=''' + @d1 + '''  ' 

                EXEC (@var) 
            END 

          FETCH next FROM perm_cur INTO @d1, @d2, @d3 
      END 

    CLOSE perm_cur 

    DEALLOCATE perm_cur 

    SELECT * 
    FROM   ##db_name 

    DROP TABLE ##db_name 

    DROP TABLE #permission
GO
