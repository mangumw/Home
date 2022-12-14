USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_PrepCard]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/13/2021
-- Description:	Migrated SSIS package to SP
-- =============================================
CREATE PROCEDURE [dbo].[usp_PrepCard] 

AS
BEGIN

SET NOCOUNT ON;
TRUNCATE TABLE WRK_INV_ONHANDS_DTL;

insert into wrk_Inv_OnHands_dtl(
Sku_number, On_Hand
)
select sku_number, On_Hand from openquery (bkl400, '
select
INUMBR as Sku_Number,
sum(IBHAND) as On_Hand
FROM MM4R4LIB.INVBAL A
WHERE 
(A.ISTORE < 105 OR (A.ISTORE > 962 AND A.ISTORE < 2100))
AND A.IBHAND <> 0
group by a.inumbr ');

UPDATE WRK_INV_ONHANDS_DTL
SET ON_HAND = (ON_HAND * -1)
END;

GO
