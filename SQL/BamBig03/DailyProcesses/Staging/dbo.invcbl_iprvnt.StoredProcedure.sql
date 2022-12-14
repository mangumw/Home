USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[invcbl_iprvnt]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[invcbl_iprvnt]
as

TRUNCATE TABLE REFERENCE.DBO.INVCBL
INSERT INTO REFERENCE.DBO.INVCBL

SELECT     INVCBL.sku_number, INVCBL.ISBN, INVCBL.Dept, INVCBL.SDept, INVCBL.Class, INVCBL.SClass, INVCBL.Vendor, INVCBL.On_Hand, 
                      INVCBL.Wk1Sales, INVCBL.Wk2Sales, INVCBL.Wk3Sales, INVCBL.Wk4Sales, INVCBL.Wk5Sales, INVCBL.Wk6Sales, INVCBL.Wk7Sales, 
                      INVCBL.Wk8Sales, INVCBL.AvgCost, INVCBL.AvgOnHand, INVCBL.AvgRetail, INVCBL.AvgInvCost, INVCBL.POOnOrder, INVCBL.TrfOnOrder, 
                      INVCBL.InTransit, INVCBL.LifeToDateUnits, INVCBL.LifeToDateDollars, INVCBL.Load_Date, IPRVNT.IPRVNT

FROM         INVCBL INNER JOIN
                      IPRVNT ON INVCBL.sku_number = IPRVNT.INUMBR
GO
