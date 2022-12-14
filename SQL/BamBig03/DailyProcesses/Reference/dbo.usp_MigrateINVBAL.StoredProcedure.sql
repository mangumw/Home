USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateINVBAL]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/13/2021
-- Description:	Migrated over from SSIS package to a SP
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateINVBAL] 

AS
BEGIN
	SET NOCOUNT ON;
--step one
Update invbal
set 
IBWKCR = 0,
On_Hand = 0, 
On_Order= 0, 
In_Transit= 0, 
Wk1_SLSU = 0, 
Wk2_SLSU = 0, 
Wk3_SLSU = 0, 
Wk4_SLSU = 0, 
Wk5_SLSU = 0, 
Wk6_SLSU = 0, 
Wk7_SLSU = 0, 
Wk8_SLSU = 0;

-- step two
truncate table invbal_tmp;

--Step 3
insert into invbal_tmp 
(sku_Number, Store_Number, IBWKCR, On_Hand, On_Order, In_transit, Transfer_OO, Wk1_SLSU, Wk2_SLSU, Wk3_SLSU, Wk4_SLSU,
Wk5_SLSU, Wk6_SLSU, Wk7_SLUSU, Wk8_SLSU)

Select inumbr,istore,ibwkcr,ibhand,ibpooq,ibtooq,ibintq,ibwk01,ibwk02,ibwk03,ibwk04,ibwk05,ibwk06,
ibwk07,ibwk08 from openquery (bkl400,'select
a.inumbr,istore,ibwkcr,ibhand,ibpooq,ibtooq,ibintq,ibwk01,ibwk02,ibwk03,ibwk04,ibwk05,ibwk06,
ibwk07,ibwk08
from 	mm4r4lib.invbal a inner join
mm4r4lib.invmst b on a.inumbr = b.inumbr inner join
mm4r4lib.invmste c on b.inumbr = c.inumbr
where ibwkcr  <> 0 or ibhand  <> 0 or ibpooq  <> 0 or ibintq  <> 0 or ibwk01  <> 0 or
ibwk02  <> 0 or ibwk03  <> 0 or ibwk04  <> 0 or ibwk05  <> 0 or ibwk06  <> 0 or
ibwk07  <> 0 or ibwk08  <> 0 and b.idsccd = ''A''') ;
--where  YEAR(IENTDT) = YEAR(GETDATE()) - 1
--(2794827 row(s) affected)

--step four 
delete invbal
from invbal_tmp as a inner join 
invbal_test as b on a.sku_number = b.sku_number and a.store_number = b.store_number;



--Step five
insert into invbal
(sku_number ,Store_Number ,IBWKCR ,On_Hand ,On_Order ,In_Transit ,Transfer_OO 
,Wk1_SLSU ,Wk2_SLSU ,Wk3_SLSU ,Wk4_SLSU ,Wk5_SLSU ,Wk6_SLSU ,Wk7_SLSU ,Wk8_SLSU)
select sku_Number, Store_Number, IBWKCR, On_Hand, On_Order, In_transit, 
Transfer_OO, Wk1_SLSU, Wk2_SLSU, Wk3_SLSU, Wk4_SLSU, Wk5_SLSU, Wk6_SLSU, Wk7_SLUSU, Wk8_SLSU 
from invbal_tmp



Select inumbr,istore,ibwkcr,ibhand,ibpooq,ibtooq,ibintq,ibwk01,ibwk02,ibwk03,ibwk04,ibwk05,ibwk06,
ibwk07,ibwk08, cast(IENTDT as Date) as IENTDT from openquery (bkl400,'select
a.inumbr,istore,ibwkcr,ibhand,ibpooq,ibtooq,ibintq,ibwk01,ibwk02,ibwk03,ibwk04,ibwk05,ibwk06,
ibwk07,ibwk08, case when IENTDT = 0 then NULL else right(concat(''0'',cast(IENTDT as varchar(6))),6) end as IENTDT
from 	mm4r4lib.invbal a inner join
mm4r4lib.invmst b on a.inumbr = b.inumbr inner join
mm4r4lib.invmste c on b.inumbr = c.inumbr
where ibwkcr  <> 0 or ibhand  <> 0 or ibpooq  <> 0 or ibintq  <> 0 or ibwk01  <> 0 or
ibwk02  <> 0 or ibwk03  <> 0 or ibwk04  <> 0 or ibwk05  <> 0 or ibwk06  <> 0 or
ibwk07  <> 0 or ibwk08  <> 0 and b.idsccd = ''A''') ;
--where  YEAR(IENTDT) = YEAR(GETDATE()) - 1



END
GO
