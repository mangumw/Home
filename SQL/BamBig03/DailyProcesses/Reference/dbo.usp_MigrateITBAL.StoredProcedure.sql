USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateITBAL]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/13/2021
-- Description:	Copied queries from SSIS package to put in a SP
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateITBAL] 

AS
BEGIN
	SET NOCOUNT ON;
truncate table ITBAL;

insert into ITBAL (
ISBN, WarehouseID, Allocated, OnBackOrder, OnPo, Price, DWCost, OnHand, Base_OnHand, InTransit,
Min_Qty, Max_Qty, Load_Date
)
Select ISBN, WarehouseID, Allocated, OnBackOrder, OnPo, Price, DWCost, OnHand, Base_OnHand, InTransit,
Min_Qty, Max_Qty, Load_Date from openquery (bkl400, 'select 	
t1.IBITNO as ISBN, t1.IBWHID as WarehouseID,
t1.IBAQT1 as Allocated, t1.IBBOQ1 OnBackOrder, t1.IBPOQ1 as OnPo, t1.IBLPR1 as Price, t1.IBSTCS as DWCost,
case
when t1.IBOHQ1 - t1.IBAQT1 < 0 then 0
else t1.IBOHQ1 - t1.IBAQT1
end as OnHand,
t1.IBOHQ1 as Base_OnHand,
case
when t1.IBAQT1-IBBOQ1< 0 then 0
else t1.IBAQT1 - IBBOQ1
end as InTransit,
IBMNo1 as Min_Qty, IBMXo1 as Max_Qty, CURRENT_TIMESTAMP as Load_Date
from 	APLUS2FAW.ITBAL t1
where	t1.IBWHID = ''1''');

/**************************************************Add Sku Number*******************************************/
update ITBAL 
set Sku_Number = case when left(ISBN,1) = 'B' Then 0 when len(ISBN) > 9 Then 0 Else ISBN End;

/**************************************************Add Return Center***********************************************/

select	
t1.ISBN,
case
when isnull(sum(t2.OnHand),0) < 0 then 0
else
isnull(sum(t2.OnHand),0)
end as ReturnCenter,
case
when isnull(sum(t3.OnHand),0) < 0 then 0
else
isnull(sum(t3.OnHand),0)
end as OtherUnpickable
into    #tmp_ITBAL_UPD
from	reference.dbo.ITBAL t1 left join 
		reference.dbo.WMBAL t2 on t2.ISBN = t1.ISBN and t2.Warehouse = t1.WarehouseID
and		(t2.Location >= '8000000000' or t2.Location = '7777777777')
left join reference.dbo.WMBAL t3 on t3.ISBN = t1.ISBN and t3.Warehouse = t1.WarehouseID
and		t3.Location in ('5555555555','6666666666','4444444444')
group by t1.ISBN
having 		(sum(t2.OnHand) > 0 or sum(t3.OnHand) > 0)
order by t1.ISBN
--
update reference.dbo.ITBAL 
set reference.dbo.ITBAL.ReturnCenter = t2.ReturnCenter,
reference.dbo.ITBAL.OtherUnpickable = t2.OtherUnpickable
from #tmp_ITBAL_upd t2
where t2.ISBN = reference.dbo.ITBAL.ISBN;
END
GO
