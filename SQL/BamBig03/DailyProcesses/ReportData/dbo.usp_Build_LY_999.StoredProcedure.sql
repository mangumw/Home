USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_LY_999]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_LY_999]
as
truncate table reportdata.dbo.LY_999
insert into Reportdata.dbo.LY_999
select	t1.sku_number,
		t1.ISBN,
		t1.Title,
		t1.Dept,
		t1.SDept,
		t1.Class,
		t1.SClass,
		t1.Author,
		t1.Pub_Code,
		t1.Sku_Type,
		t1.lyWeek1Dollars,
		t1.lyWeek1Units,
		t1.retail,
		getdate() as Load_Date
from	dssdata.dbo.card t1
where	t1.Dept IN ('1', '3', '4', '5', '6', '8','12','13', '10','58')

		
GO
