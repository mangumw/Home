USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_Clear_INVBAL_tables]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [dbo].[usp_Clear_INVBAL_tables]
as

truncate table reference..invbal_tmp
GO
