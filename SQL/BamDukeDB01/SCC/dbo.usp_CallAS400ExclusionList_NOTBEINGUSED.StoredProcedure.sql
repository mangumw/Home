USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_CallAS400ExclusionList_NOTBEINGUSED]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/27/2021
-- Description:	Calls Funtion in DB2 for Exclusion Lookup
-- =============================================
CREATE PROCEDURE [dbo].[usp_CallAS400ExclusionList_NOTBEINGUSED] @Store int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Declare @Store int
Declare @Sku int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))
set @Sku = (Select sku from tblScannedItems where storenumber = @Store and Batchpass = 1 and BatchNumber = 5)

--Select @Store as StoreNumber, @Sku as Sku
Exec ('Call MMRNRLIB.cyclevalid (?)', @Store, @sku) AT bkl400 --Sku and store

Select @Store as StoreNumber, @Sku as Sku

END

GO
