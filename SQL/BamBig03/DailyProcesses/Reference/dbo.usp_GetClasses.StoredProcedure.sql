USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetClasses]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create  procedure [dbo].[usp_GetClasses]
@Dept varchar(5),
@SubDept varchar(5)
as
if @Dept = '<All>' OR @SubDept = '<All>'
  select '<All>' as Class
else
begin
select distinct Class from Reference.dbo.Category_Master
where Dept = ltrim(str(cast(@dept as int)))
and SubDept = ltrim(str(cast(@SubDept as int)))
union all 
select all_indicator from reference.dbo.all_indicators
order by Class
end

GO
