USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_C4RequestNextBatch4_NOTBEINGUSED]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/17/2021
-- Description:	Request new batch
-- =============================================
CREATE PROCEDURE [dbo].[usp_C4RequestNextBatch4_NOTBEINGUSED] @Store int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Declare @Store int
set @Store = (select StoreNumber from tblStores where StoreNumber IN ( select StoreNumber from tblStores where StoreNumber = @Store))

  
  create table #tmp(
  Name varchar (5),
  BatchNumber varchar(2),
  StoreNumber varchar(5)
  )
  insert into #tmp
  Select top 1
  'BATCH' as Name,
  '99' as BatchNumber,
  cast(@Store as varchar (5)) as StoreNumber
  from tblStores s left join
  tblBatches b on s.StoreNumber = b.StoreNumber
  where s.StoreNumber = @Store

insert openquery (bkl400, 'select SSC_CMD, SSC_TIME from MM4R4LIB.sqlsvrcmd') 
Select Name + ' ' +BatchNumber+ ' ' +'00'+StoreNumber as SCC_CMD, getdate() SSC_TIME from #tmp

drop table #tmp
END

GO
