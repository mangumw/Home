USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetSubClasses]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create  procedure [dbo].[usp_GetSubClasses]
@Dept varchar(5),
@SubDept varchar(5),
@Class varchar(5)
as
if @Dept = '<All>' OR @SubDept = '<All>' or @Class = '<All>'
  select '<All>' as SubClass
else
begin
select distinct SubClass from Reference.dbo.Category_Master
where Dept = ltrim(str(cast(@dept as int)))
and SubDept = ltrim(str(cast(@SubDept as int)))
and Class = ltrim(str(cast(@Class as int)))
union all 
select all_indicator from reference.dbo.all_indicators
order by SubClass
end


GO
