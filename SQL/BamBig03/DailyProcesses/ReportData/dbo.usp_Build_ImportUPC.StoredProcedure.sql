USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_ImportUPC]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_ImportUPC]
as
drop table ReportData.dbo.ImportUPC
SELECT T1.sku_number, T2.Pub_code, T1.UPC
INTO ReportData.dbo.ImportUPC
FROM reference..INVUPC T1 
INNER JOIN reference..INVMST T2 
ON T1.sku_number = T2.sku_number
WHERE (((T2.pub_code) In ('AFE','IFH')))

GO
