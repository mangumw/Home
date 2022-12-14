USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_terrorist_list]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_rpt_terrorist_list]
AS

--Build Last_Name Query1-
TRUNCATE TABLE staging.dbo.Name_Match
INSERT INTO staging.dbo.Name_Match
SELECT     DBHREMP.LAST_NAME, DBHREMP.FIRST_NAME, DBHREMP.COUNTRY_CODE, DBHREMP.ZIP, DBHREMP.STATE, DBHREMP.CITY, 
                      DBHREMP.ADDR4, DBHREMP.ADDR3, DBHREMP.ADDR2, DBHREMP.ADDR1, DBHREMP.EMPLOYEE, DBHREMP.COMPANY
FROM         reference.dbo.DBHREMP INNER JOIN
                      
                  
                      staging.dbo.OFAS
                      
                       ON DBHREMP.FIRST_NAME = OFAS.[first_name] AND DBHREMP.LAST_NAME = OFAS.[last_name]

--Build Alias Query2-
TRUNCATE TABLE staging.dbo.Alias_Match
INSERT INTO staging.dbo.Alias_Match
SELECT     DBHREMP.COMPANY, DBHREMP.EMPLOYEE, DBHREMP.LAST_NAME, DBHREMP.FIRST_NAME, DBHREMP.ADDR1, DBHREMP.ADDR2, 
                      DBHREMP.ADDR3, DBHREMP.ADDR4, DBHREMP.CITY, DBHREMP.STATE, DBHREMP.ZIP, DBHREMP.COUNTRY_CODE
FROM         reference.dbo.DBHREMP INNER JOIN
                      Staging.dbo.OFAS ON DBHREMP.LAST_NAME = Staging.dbo.OFAS.[last_name] AND DBHREMP.FIRST_NAME = Staging.dbo.OFAS.[first_name]


--Build Vendor query 3-
TRUNCATE TABLE staging.dbo.Vendor_Match
INSERT INTO staging.dbo.Vendor_Match
SELECT     t1.VENDOR_SNAME
FROM        reference..DBAPVEN AS t1 CROSS JOIN
                      Staging.dbo.OFAS AS t2
WHERE     t2.[last_name] + ' ' + t2.[first_name] = t1.Vendor_VName


--Build Vendor_Alias query 4
TRUNCATE TABLE staging.dbo.Vendor_Match_Alias
INSERT INTO staging.dbo.Vendor_Match_Alias
SELECT     t1.VENDOR_SNAME
FROM         reference..DBAPVEN AS t1 CROSS JOIN
                      Staging.dbo.OFAS AS t2
WHERE     t2.[last_name] + ' ' + t2.[first_name] = t1.Vendor_SName

GO
