USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetSubDepartments]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  procedure [dbo].[usp_GetSubDepartments]
@Dept varchar(6)
as
if @dept = '<All>'
	select @Dept as Sub_Dept
else
begin
select distinct SubDept as Sub_Dept from Reference.dbo.category_master
where Dept = ltrim(str(cast(@dept as int)))
union all 
select all_indicator from reference.dbo.all_indicators
order by Sub_Dept
end



GO
