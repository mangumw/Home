USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_misc_scans]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[usp_misc_scans]
As


declare @sd smalldatetime
declare @ed smalldatetime

select @ed = staging.dbo.fn_Last_Saturday(Getdate())
select @sd = Dateadd(dd,-6,@ed)

truncate table staging.dbo.misc_scan1
insert into staging.dbo.misc_scan1 

SELECT     DssData.dbo.Detail_Transaction_History.Store_Number, Reference.dbo.Store_Dim.store_name, Reference.dbo.Item_Master.Dept, 
                      DssData.dbo.Detail_Transaction_History.Cashier_Nbr, SUM(DssData.dbo.Detail_Transaction_History.Item_Quantity) AS ttlqty
FROM         DssData.dbo.Detail_Transaction_History INNER JOIN
                      Reference.dbo.Item_Master ON DssData.dbo.Detail_Transaction_History.Sku_Number = Reference.dbo.Item_Master.SKU_Number INNER JOIN
                      Reference.dbo.Store_Dim ON DssData.dbo.Detail_Transaction_History.Store_Number = Reference.dbo.Store_Dim.store_number
WHERE     (DssData.dbo.Detail_Transaction_History.Day_Date BETWEEN @sd AND @ed)
GROUP BY DssData.dbo.Detail_Transaction_History.Store_Number, DssData.dbo.Detail_Transaction_History.Cashier_Nbr, Reference.dbo.Item_Master.Dept, 
                      Reference.dbo.Store_Dim.store_name


truncate table staging.dbo.misc_scan2
insert into staging.dbo.misc_scan2 


SELECT     DssData.dbo.Detail_Transaction_History.Store_Number, Reference.dbo.Store_Dim.store_name, Reference.dbo.Item_Master.Dept, 
                      DssData.dbo.Detail_Transaction_History.Cashier_Nbr, SUM(DssData.dbo.Detail_Transaction_History.Item_Quantity) AS ttlqty
FROM         DssData.dbo.Detail_Transaction_History INNER JOIN
                      Reference.dbo.Item_Master ON DssData.dbo.Detail_Transaction_History.Sku_Number = Reference.dbo.Item_Master.SKU_Number INNER JOIN
                      Reference.dbo.Store_Dim ON DssData.dbo.Detail_Transaction_History.Store_Number = Reference.dbo.Store_Dim.store_number
WHERE     (DssData.dbo.Detail_Transaction_History.Day_Date BETWEEN @sd AND @ed) AND (Reference.dbo.Item_Master.SKU_Number IN (1, 2, 3, 4, 5, 6, 8, 
                      10, 12, 16, 69, 58, 13, 14, 16))
GROUP BY DssData.dbo.Detail_Transaction_History.Store_Number, DssData.dbo.Detail_Transaction_History.Cashier_Nbr, Reference.dbo.Item_Master.Dept, 
                      Reference.dbo.Store_Dim.store_name


SELECT     misc_scan1.Store_Number, misc_scan1.store_name, misc_scan1.Dept, misc_scan1.Cashier_Nbr, misc_scan1.ttlqty AS ttl, ISNULL(misc_scan2.ttlqty, 
                      0) AS ttl2, CASE WHEN isnull(Staging.dbo.misc_scan1.ttlqty, 0) = 0 OR
                      isnull(staging.dbo.misc_scan2.ttlqty, 0) = 0 THEN 0 ELSE misc_scan2.ttlqty / Staging.dbo.misc_scan1.ttlqty END AS ttl3
FROM         misc_scan1 LEFT OUTER JOIN
                      misc_scan2 ON misc_scan1.Store_Number = misc_scan2.Store_Number AND misc_scan1.store_name = misc_scan2.store_name AND 
                      misc_scan1.Dept = misc_scan2.Dept AND misc_scan1.Cashier_Nbr = misc_scan2.Cashier_Nbr

truncate table ReportData.dbo.rpt_Misc_Scans
insert into ReportData.dbo.rpt_Misc_Scans
SELECT  misc_scan1.Store_Number, 
		misc_scan1.store_name, 
		misc_scan1.Dept, 
		misc_scan1.Cashier_Nbr, 
		misc_scan1.ttlqty AS ttl, 
		ISNULL(misc_scan2.ttlqty,0) AS ttl2, 
		CASE WHEN isnull(Staging.dbo.misc_scan1.ttlqty, 0) = 0 OR
                  isnull(staging.dbo.misc_scan2.ttlqty, 0) = 0 THEN 0 
		ELSE cast(misc_scan2.ttlqty as float) / cast(Staging.dbo.misc_scan1.ttlqty as float) END AS ttl3
FROM    misc_scan1 LEFT OUTER JOIN
        misc_scan2 ON misc_scan1.Store_Number = misc_scan2.Store_Number AND misc_scan1.store_name = misc_scan2.store_name AND 
        misc_scan1.Dept = misc_scan2.Dept AND misc_scan1.Cashier_Nbr = misc_scan2.Cashier_Nbr



GO
