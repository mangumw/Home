USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Active_Stores]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Active_Stores]
as
truncate table reference.dbo.active_stores
insert into reference.dbo.active_stores

SELECT     Reference.dbo.Region_Dim.region_number, Reference.dbo.Region_Dim.region_name, Reference.dbo.District_Dim.district_number, 
                      Reference.dbo.District_Dim.district_name, Reference.dbo.TBLSTR.STRNUM AS Store_number, Reference.dbo.TBLSTR.STRNAM AS Store_name, ' ' AS DM_Email

FROM         Reference.dbo.TBLSTR INNER JOIN
                      Reference.dbo.District_Dim ON Reference.dbo.TBLSTR.STRDST = Reference.dbo.District_Dim.district_number INNER JOIN
                      Reference.dbo.Region_Dim ON Reference.dbo.TBLSTR.REGNUM = Reference.dbo.Region_Dim.region_number
WHERE     (Reference.dbo.TBLSTR.STRNUM > 100) AND (NOT (Reference.dbo.TBLSTR.STRNUM IN (986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 2575, 999, 
                      1000, 3108, 3134, 3176, 3197, 3240, 3253, 3286, 3313, 3387, 3487, 3515, 3517, 3575, 3577, 3622, 3658, 3777, 9999, 2995, 2997, 4001, 4002, 4003, 
						4004, 4005, 4006,4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4017, 99999))) AND (NOT (Reference.dbo.Region_Dim.region_name LIKE '%CLOSED%')) AND 
                      (Reference.dbo.TBLSTR.STCLDT = 0) AND (Reference.dbo.TBLSTR.STRHDO = 'S')
ORDER BY Store_number
GO
