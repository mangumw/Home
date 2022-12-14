USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[proc_genscript]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.proc_genscript    Script Date: 5/8/2003 11:06:53 AM ******/

CREATE PROCEDURE [dbo].[proc_genscript] 
	@ServerName varchar(30), 
	@DBName varchar(30), 
	@ObjectName varchar(50), 
	@ObjectType varchar(10), 
	@TableName varchar(50),
	@ScriptFile varchar(255)
AS

DECLARE @CmdStr varchar(255)
DECLARE @object int
DECLARE @hr int

SET NOCOUNT ON
SET @CmdStr = 'Connect('+@ServerName+')'
EXEC @hr = sp_OACreate 'SQLDMO.SQLServer', @object OUT

--Comment out for standard login
--EXEC @hr = sp_OASetProperty @object, 'LoginSecure', TRUE

-- Uncomment for Standard Login
EXEC @hr = sp_OASetProperty @object, 'Login', 'infausr'
EXEC @hr = sp_OASetProperty @object, 'password', 'ri5j6c02'


EXEC @hr = sp_OAMethod @object,@CmdStr
SET @CmdStr = 
  CASE @ObjectType
    WHEN 'Database' 	THEN 'Databases("' 
    WHEN 'Procedure'	THEN 'Databases("' + @DBName + '").StoredProcedures("'
    WHEN 'View' 	THEN 'Databases("' + @DBName + '").Views("'
    WHEN 'Table'	THEN 'Databases("' + @DBName + '").Tables("'
    WHEN 'Index'	THEN 'Databases("' + @DBName + '").Tables("' + @TableName + '").Indexes("'
    WHEN 'Trigger'	THEN 'Databases("' + @DBName + '").Tables("' + @TableName + '").Triggers("'
    WHEN 'Key'	THEN 'Databases("' + @DBName + '").Tables("' + @TableName + '").Keys("'
    WHEN 'Check'	THEN 'Databases("' + @DBName + '").Tables("' + @TableName + '").Checks("'
    WHEN 'Job'	THEN 'Jobserver.Jobs("'
  END

SET @CmdStr = @CmdStr + @ObjectName + '").Script(5,"' + @ScriptFile + '")'
EXEC @hr = sp_OAMethod @object, @CmdStr
EXEC @hr = sp_OADestroy @object

GO
