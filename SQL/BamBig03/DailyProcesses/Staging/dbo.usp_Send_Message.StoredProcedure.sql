USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Send_Message]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Send_Message]
@to varchar(4000),
@Sub varchar(4000),
@Msg varchar(4000)
as
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'infausr',
    @recipients = @to,
    @body = @msg,
    @subject = @sub;



GO
