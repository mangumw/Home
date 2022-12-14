USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Comp_Store]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Build_Comp_Store]
AS 


truncate table reference.dbo.comp_stores
insert into reference.dbo.comp_stores
SELECT     Reference.dbo.TBLSTR.STRNUM, Reference.dbo.TBLSTR.STRNAM, Reference.dbo.Region_Dim.region_number, 
                      Reference.dbo.Region_Dim.region_name, Reference.dbo.District_Dim.district_number, Reference.dbo.District_Dim.district_name
FROM         Reference.dbo.TBLSTR INNER JOIN
                      Reference.dbo.District_Dim ON Reference.dbo.TBLSTR.STRDST = Reference.dbo.District_Dim.district_number INNER JOIN
                      Reference.dbo.Region_Dim ON Reference.dbo.TBLSTR.REGNUM = Reference.dbo.Region_Dim.region_number
WHERE     (Reference.dbo.TBLSTR.STRCMP = 'C') AND (Reference.dbo.TBLSTR.STRNUM BETWEEN 100 AND 985) AND 
                      (NOT (Reference.dbo.TBLSTR.STRNUM IN (986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 2100, 2101, 1000))) AND 
                      (NOT (Reference.dbo.Region_Dim.region_name LIKE '%CLOSED%')) AND (Reference.dbo.TBLSTR.STCLDT = 0)
ORDER BY Reference.dbo.TBLSTR.STRNUM
GO
