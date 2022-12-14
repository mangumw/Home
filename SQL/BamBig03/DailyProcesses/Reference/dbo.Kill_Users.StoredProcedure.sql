USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[Kill_Users]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Kill_Users]


AS
	DECLARE @v_spid INT
DECLARE c_Users CURSOR
   FAST_FORWARD FOR
   SELECT SPID
   FROM master..sysprocesses (NOLOCK)
   WHERE spid>50 
   AND status='sleeping' 
   AND DATEDIFF(mi,last_batch,GETDATE())>=60
   AND spid<>@@spid
   AND UPPER(nt_username) <> 'INFAUSR'

OPEN c_Users
FETCH NEXT FROM c_Users INTO @v_spid
WHILE (@@FETCH_STATUS=0)
BEGIN
  PRINT 'KILLing '+CONVERT(VARCHAR,@v_spid)+'...'
  EXEC('KILL '+@v_spid)
  FETCH NEXT FROM c_Users INTO @v_spid
END

CLOSE c_Users
DEALLOCATE c_Users
GO
