USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateDepartments]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/24/2021
-- Description:	Imports INVDPT for Department Names and ID's
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateDepartments] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

insert into tblDepartments
Select Department, SubDepartment, Class, Subclass, DepartmentName 
from openquery(bkl400, 'Select idept as Department, isdept as SubDepartment, iclas as Class, isclas as SubClass, dptnam as DepartmentName from mm4r4lib.invdpt')
Where Department is null


END


GO
