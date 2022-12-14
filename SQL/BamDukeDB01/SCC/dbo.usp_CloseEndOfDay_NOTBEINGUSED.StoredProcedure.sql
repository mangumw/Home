USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CloseEndOfDay_NOTBEINGUSED]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/08/2021
-- Description:	Close End of Day
-- =============================================
CREATE PROCEDURE [dbo].[usp_CloseEndOfDay_NOTBEINGUSED] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
update openquery (bkl400, 'select CCPRCFLG from MM4R4LIB.CYCTBATCH where CCPRCFLG is null')
set  CCPRCFLG = (
Select  
case
when b.StatusID = 3 then ''
when b.StatusID = 2 then '2' end as StatusID
from OpenQuery
(bkl400, 'Select CCPRCFLG, CCINUMBR, CCISTORE from MM4R4LIB.CYCTBATCH') a  inner join 
tblBatchDetails bd on a.CCINUMBR = bd.SKU and a.CCISTORE = bd.StoreNumber inner join
tblBatches b on bd.BatchNumber = b.BatchNumber and a.CCISTORE = b.StoreNumber
where b.StatusID <> 4 and  b.Storenumber = @Store and b.BatchDate = dateadd(dd,datediff(dd,0,getdate()),0) and a.CCISTORE = @Store )
 RETURN
END


GO
