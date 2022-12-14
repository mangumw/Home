USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[active_stores_Fuse]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[active_stores_Fuse]
AS


truncate table reference.dbo.active_stores_FUSE
insert into reference.dbo.active_stores_FUSE
SELECT     Reference.dbo.Region_Dim.region_number, Reference.dbo.Region_Dim.region_name, Reference.dbo.District_Dim.district_number, 
                      Reference.dbo.District_Dim.district_name, Reference.dbo.TBLSTR.STRNUM AS Store_number, Reference.dbo.TBLSTR.STRNAM AS Store_name, 
                      ' ' as DM_Email
FROM         Reference.dbo.TBLSTR INNER JOIN
                      Reference.dbo.District_Dim ON Reference.dbo.TBLSTR.STRDST = Reference.dbo.District_Dim.district_number INNER JOIN
                      Reference.dbo.Region_Dim ON Reference.dbo.TBLSTR.REGNUM = Reference.dbo.Region_Dim.region_number
WHERE     (Reference.dbo.TBLSTR.STRNUM BETWEEN 100 AND 985) AND (NOT (Reference.dbo.TBLSTR.STRNUM IN (986, 987, 988, 989, 990, 991, 992, 993, 
                      994, 995, 996, 997, 998, 2575, 999, 2100, 2101, 1000))) AND (NOT (Reference.dbo.Region_Dim.region_name LIKE '%CLOSED%')) AND 
                      (Reference.dbo.TBLSTR.STCLDT = 0)
ORDER BY Store_number
GO
