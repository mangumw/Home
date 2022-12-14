USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateDepartments]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 11/18/2021
-- Description:	migrates INVDPT from as400 into Departments table
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateDepartments]
AS
BEGIN
truncate table StagingDepartments
truncate table Departments

insert into StagingDepartments (Department,
SubDepartment,
Class,
SubClass,
DepartmentName,
DepartmentSection,
DepartmentPlan,
BuyerNumber
)
Select Department,
SubDepartment,
Class,
SubClass,
DepartmentName,
DepartmentSection,
DepartmentPlan,
BuyerNumber from openquery (bkl400, 'select IDEPT as Department,
ISDEPT as SubDepartment,
ICLAS as Class,
ISCLAS as SubClass,
DPTNAM as DepartmentName,
DPTSHT as DepartmentSection,
IDPLAN as DepartmentPlan,
IDBUYR as BuyerNumber from mm4r4lib.invdpt')

insert into Departments (BuyerID,
Department,
SubDepartment,
Class,
SubClass,
DepartmentName,
DepartmentSection,
DepartmentPlan,
BuyerNumber 
)
Select 
b.BuyerID,
Department,
SubDepartment,
Class,
SubClass,
DepartmentName,
DepartmentSection,
DepartmentPlan,
d.BuyerNumber
from StagingDepartments d left join
Buyers b on d.BuyerNumber = b.BuyerNumber
END
GO
