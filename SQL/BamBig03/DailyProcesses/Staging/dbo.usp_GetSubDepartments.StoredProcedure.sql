USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetSubDepartments]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_GetSubDepartments]
@Dept varchar(5)
as
select SubDept from Reference.dbo.Category_Master
where Dept = @dept

GO
