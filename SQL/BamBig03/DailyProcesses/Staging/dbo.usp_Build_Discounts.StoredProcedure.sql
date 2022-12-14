USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Discounts]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Discounts]
as
declare @LS int
select @LS = staging.dbo.fn_DateToInt(getdate())

truncate table reportdata.dbo.Discounts
insert into reportdata.dbo.Discounts
SELECT	t1.ISBN, 
		t2.PLNITM, 
		t2.PLNTYP, 
		t2.PLNCDT, 
		t2.PLNADT, 
		t2.PLNAMT, 
		t2.PLNFLG, 
		t1.POS_Price, 
		([POS_Price]-[PLNAMT])/[POS_Price] AS Discount
FROM	reference.dbo.PRCPLN t2 INNER JOIN reference.dbo.item_master t1 
ON		t2.PLNITM = t1.SKU_Number

GROUP BY t1.ISBN, t2.PLNITM, t2.PLNTYP, t2.PLNCDT, t2.PLNADT, t2.PLNAMT, t2.PLNFLG, t1.POS_Price, ([POS_Price]-[PLNAMT])/[POS_Price]

HAVING	(((t2.PLNTYP)=7) 
AND		((t2.PLNCDT)<@LS) 
AND		((t2.PLNADT)>@LS) 
AND		((t2.PLNFLG)=1));

GO
