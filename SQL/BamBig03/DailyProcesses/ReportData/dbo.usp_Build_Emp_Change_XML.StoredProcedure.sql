USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Emp_Change_XML]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Emp_Change_XML]
as
SELECT 1 AS Tag,
	NULL AS Parent,
	'' AS [DOCUMENT!1],
	NULL AS [USER!2!ACTIONS],
	NULL AS [USER!2!USERID!element],
	NULL AS [USER!2!PASSWORD!element],
	NULL AS [USER!2!EMPNO!element],
	NULL AS [USER!2!GNAME!element],
	NULL AS [USER!2!FNAME!element],
	NULL AS [USER!2!OTHERNAME!element],
	NULL AS [USER!2!JOINDATE!element],
	NULL AS [USER!2!LEVEL1!element],
	NULL AS [USER!2!LEVEL1DESC!element],
	NULL AS [USER!2!LEVEL2!element],
	NULL AS [USER!2!LEVEL2DESC!element],
	NULL AS [USER!2!LEVEL3!element],
	NULL AS [USER!2!LEVEL3DESC!element],
	NULL AS [USER!2!LEVEL4!element],
	NULL AS [USER!2!LEVEL4DESC!element],
	NULL AS [USER!2!STATUS!element],
	NULL AS [USER!2!USERATTR1!element],
	NULL AS [USER!2!USERATTR2!element],
	NULL AS [USER!2!USERROLE!element],
	NULL AS [USER!2!JOBTITLE!element],
	NULL AS [USER!2!DEPARTMENTNAME!element]
UNION ALL
SELECT 2 AS Tag,
	1 AS Parent,
	'' AS [TEST!1],
	CASE Action 
		WHEN 'Termination' THEN 'UPDATE' 
		WHEN 'New Hire' THEN 'CREATE' 
		ELSE 'UPDATE' 
	END 				AS [USER!2!ACTIONS],
	Employee			AS [USER!2!USERID],
	'bam' + substring(SSN,5,2) + right(rtrim(SSN),4) AS [USER!2!PASSWORD],
	Employee			AS [USER!2!EMPNO],
	RTRIM(Last_Name)	AS [USER!2!GNAME],
	RTRIM(First_Name)	AS [USER!2!FNAME],
	RTRIM(Initial)		AS [USER!2!OTHERNAME],
	staging.dbo.fn_CharDate(Hire_Date) + ' 00:00:00'	AS [USER!2!JOINDATE],
	CASE Action
	    WHEN	'Termination' then 'IN'
	    else	'BAM'
	END			AS [USER!2!LEVEL1],
	CASE Action
		WHEN	'Termination' then 'Inactive Users'
		else	'Books-A-Million'
	END					AS [USER!2!LEVEL1DESC],
    case Action
        WHEN	'Termination' then ' '
        Else	str(Region_Number)
	end			AS [USER!2!LEVEL2],
    case Action
        WHEN	'Termination' then ''
		else	'Region ' + ltrim(str(Region_Number)) 	
	END			AS [USER!2!LEVEL2DESC],
    case Action
        WHEN	'Termination' then ''
		else	str(District_Number)	
	END			AS [USER!2!LEVEL3],
    case Action
        WHEN	'Termination' then ''
		else	'District ' + ltrim(str(District_Number)) 
	END			AS [USER!2!LEVEL3DESC],
    case Action
        WHEN	'Termination' then ''
		else	right(Store_Number,3) 
	End			AS [USER!2!LEVEL4],
    case Action
        WHEN	'Termination' then ''
		else	'Store ' + ltrim(str(Store_Number)) 
	End			AS [USER!2!LEVEL4DESC],
	CASE Action
		WHEN	'Termination' then '1'
		ELSE	'0'
	END					AS [USER!2!STATUS],
	substring(Job_Code,5,6) AS [USER!2!USERATTR1],
	case Emp_Status
		when 'A1' then 'AF'
		when 'A2' then 'AP'
		when 'A3' then 'AS'
		else 'IN'
	end 				AS [USER!2!USERATTR2],
	CASE JOB_CODE
		WHEN 'Manager' then 'M'
		WHEN 'CoManager' then 'M'
		ELSE 'S'
	END					AS [USER!2!USERROLE],
	RTRIM(substring(Job_Code,5,9))		AS [USER!2!JOBTITLE],
	Store_Number		AS [USER!2!DEPARTMENTNAME]
FROM ReportData.dbo.rpt_Emp_Status_Change R
where isnumeric(store_number) = 1
FOR XML EXPLICIT ,BINARY BASE64
GO
