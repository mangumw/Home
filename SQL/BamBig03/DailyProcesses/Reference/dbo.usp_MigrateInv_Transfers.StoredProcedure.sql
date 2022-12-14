USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateInv_Transfers]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 08/24/2021
-- Description:	Inventory Transfer Migration
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateInv_Transfers] 

AS
BEGIN

--SET NOCOUNT ON;

/*******************************************************Truncate incase another process left items in table****************************************************/
truncate table staging.dbo.tmp_TRFHDR
truncate table Staging.dbo.tmp_TRFDTL

/********************************************Migrate TRFHDR from as400***************************************************************/
insert into staging.dbo.tmp_TRFHDR
(TRFBCH,TRFSTS,TRFTYP,TRFPTY,TRFFLC,TRFTLC,TRFICN,TRFIDT,TRFBCN,TRFBDT,TRFSCN,TRFSDT,TRFRCN,TRFRDT
,TRFINS,TRFDLC,TRFREF,TRFPYN,TRINIT,TRFPO#,TRFBO#,THTUNT,THTPCK,THTPLT,THTCTN,THTIPK,THTRTA,THTCST
,THTCUB,THTUNP,THTPLP,THTCTP,THTIPP,THTRTP,THTCSP,THTPCU,TRPKLN,THCYCL,THSCWV,THSCSQ,THSCNM,TRFXRF
,THCNYN)

select TRFBCH,TRFSTS,TRFTYP,TRFPTY,TRFFLC,TRFTLC,TRFICN,TRFIDT,TRFBCN,TRFBDT,TRFSCN,TRFSDT,TRFRCN,TRFRDT
,TRFINS,TRFDLC,TRFREF,TRFPYN,TRINIT,TRFPO#,TRFBO#,THTUNT,THTPCK,THTPLT,THTCTN,THTIPK,THTRTA,THTCST
,THTCUB,THTUNP,THTPLP,THTCTP,THTIPP,THTRTP,THTCSP,THTPCU,TRPKLN,THCYCL,THSCWV,THSCSQ,THSCNM,TRFXRF
,THCNYN from openquery (bkl400, 'Select TRFBCH,TRFSTS,TRFTYP,TRFPTY,TRFFLC,TRFTLC,TRFICN,right(concat(''0'',cast(TRFIDT as varchar(6))),6) as TRFIDT,
TRFBCN,TRFBDT,TRFSCN,TRFSDT,TRFRCN,TRFRDT,TRFINS,TRFDLC,TRFREF,TRFPYN,TRINIT,TRFPO#,TRFBO#,THTUNT,THTPCK,THTPLT,THTCTN,THTIPK,THTRTA,THTCST
,THTCUB,THTUNP,THTPLP,THTCTP,THTIPP,THTRTP,THTCSP,THTPCU,TRPKLN,THCYCL,THSCWV,THSCSQ,THSCNM,TRFXRF,THCNYN 
from mm4r4lib.trfhdr where TRFIDT >= varchar_format (current date -90 days, ''YYMMDD'') order by TRFIDT')


/****************************************************Insert into Production*******************************************************/
INSERT INTO Reference.dbo.TRFHDR
(Transfer_Batch,Transfer_Status,Transfer_Type,Transfer_Priority,From_Store,To_Store,Init_Century,Init_Date,Ship_By_Date_Cen
,Ship_By_Date,Ship_Date_Cen,Ship_Date,Recv_Date_Cen,Recv_Date,Spec_Instr,Def_Warehouse_Slot,Transfer_Ref_Number,Ship_Doc_Printed
,Transfer_Init_By_COD,PO_Number,BO_Number,Total_Units_Req,Total_Picks_Req,Total_Pallets_Req,Total_Cartons_Req,Total_Inner_Packs
,Total_Retail_Value,Total_Cost_Value,Total_Cube_Measure,Total_Units_Picked,Total_Pallets_Picked,Total_Cartons_Picked,Total_Inner_Packs_Picked
,Total_Retail_Value_Of_All,Total_Cost_Value_Of_All,Total_Cubic_Measure_Of_All,Transfer_Lines_To_Pick,Warehouse_Cycle_Number,Schedule_Wave_Number
,Schedule_Wave_Seq,Schedule_Name,Transfer_XRef,Colsolidate_Transfer)

select TRFBCH as Transfer_Batch, TRFSTS as Transfer_Status, TRFTYP as Transfer_Type, TRFPTY as Transfer_Priority, TRFFLC as From_Store, 
TRFTLC as To_Store, TRFICN as Init_Century, cast(cast(TRFIDT as varchar(8)) as Date) as Init_Date, TRFBCN as Ship_By_Date_Cen, 
cast(cast(TRFBDT as varchar(8)) as Date) as Ship_By_Date, 
TRFSCN as Ship_Date_Cen, 
case when TRFSDT = 0 then null
else cast(cast(TRFSDT as varchar(8)) as Date) end as Ship_Date, 
TRFRCN as Recv_Date_Cen, 
case when TRFRDT = 0 then null
else cast(cast(TRFRDT as varchar(8)) as Date) end as Recv_Date, 
TRFINS as Spec_Instr, TRFDLC as Def_Warehouse_Slot, 
TRFREF as Transfer_Ref_Number, TRFPYN as Ship_Doc_Printed, TRINIT as Transfer_Init_By_COD, TRFPO# as PO_Number, TRFBO# as BO_Number, 
THTUNT as Total_Units_Req, THTPCK as Total_Picks_Req, THTPLT as Total_Pallets_Req, THTCTN as Total_Cartons_Req, THTIPK as Total_Inner_Packs, 
THTRTA as Total_Retail_Value, THTCST as Total_Cost_Value, THTCUB as Total_Cube_Measure, THTUNP as Total_Units_Picked, THTPLP as Total_Pallets_Picked, 
THTCTP as Total_Cartons_Picked, THTIPP as Total_Inner_Packs_Picked, THTRTP as Total_Retail_Value_Of_All, THTCSP as Total_Cost_Value_Of_All, 
THTPCU as Total_Cubic_Measure_Of_All, TRPKLN as Transfer_Lines_To_Pick, THCYCL as Warehouse_Cycle_Number, THSCWV as Schedule_Wave_Number, 
THSCSQ as Schedule_Wave_Seq, THSCNM as Schedule_Name, TRFXRF as Transfer_XRef, THCNYN as Colsolidate_Transfer
from staging.dbo.tmp_TRFHDR as st left join
Reference.dbo.trfhdr as p on st.TRFBCH = p.Transfer_Batch
where p.Transfer_Batch is null


/**********************Updates the last 89 days for any changes and updating dates for shipping and Recv Dates***********************/
update p
set 
p.Init_Date = cast(cast(TRFIDT as varchar(8)) as Date),
p.Ship_By_Date = cast(cast(TRFBDT as varchar(8)) as Date),
p.Ship_Date = case when TRFSDT = 0 then null else cast(cast(TRFSDT as varchar(8)) as Date) end,
p.Recv_Date = case when TRFRDT = 0 then null else cast(cast(TRFRDT as varchar(8)) as Date) end
from staging.dbo.tmp_TRFHDR as st inner join
Reference.dbo.trfhdr as p on st.TRFBCH = p.Transfer_Batch
where Init_Date > DATEADD(DAY, -89, GETDATE())


/***********************************************Migrate TRFDTL from as400***********************************************/
insert into staging.dbo.tmp_TRFDTL(
TRFBCH, TRFFLC, TRFTLC, INUMBR, ASNUM, IDEPT, ISDEPT, ICLAS, ISCLAS, TRFREQ, TRFSHP,
TRFREC, TRFALC, TRFSUB, TRFSCD, TRFRLC, TRFCST, TRFRIN, TRFROU, ICUBE, IVNDP#, TRFSTS,
TRFTYP, TRFPTY, TDCYCL, TDSCWV, TDSCSQ, TDSCNM, TRSVND, TRSTYL, TRSCOL, TRSSIZ, TRSDIM,
TRFDSP, TDSCQT, TDRCQT, TDWGHT)

select TRFBCH, TRFFLC, TRFTLC, INUMBR, ASNUM, IDEPT, ISDEPT, ICLAS, ISCLAS, TRFREQ, TRFSHP,
TRFREC, TRFALC, TRFSUB, TRFSCD, TRFRLC, TRFCST, TRFRIN, TRFROU, ICUBE, IVNDP#, TRFSTS,
TRFTYP, TRFPTY, TDCYCL, TDSCWV, TDSCSQ, TDSCNM, TRSVND, TRSTYL, TRSCOL, TRSSIZ, TRSDIM,
TRFDSP, TDSCQT, TDRCQT, TDWGHT  from openquery (bkl400,'Select
d.TRFBCH, d.TRFFLC, d.TRFTLC, d.INUMBR, d.ASNUM, d.IDEPT, d.ISDEPT, d.ICLAS, d.ISCLAS, d.TRFREQ, d.TRFSHP,
d.TRFREC, d.TRFALC, d.TRFSUB, d.TRFSCD, d.TRFRLC, d.TRFCST, d.TRFRIN, d.TRFROU, d.ICUBE, d.IVNDP#, d.TRFSTS,
d.TRFTYP, d.TRFPTY, d.TDCYCL, d.TDSCWV, d.TDSCSQ, d.TDSCNM, d.TRSVND, d.TRSTYL, d.TRSCOL, d.TRSSIZ, d.TRSDIM,
d.TRFDSP, d.TDSCQT, d.TDRCQT, d.TDWGHT 
from mm4r4lib.trfhdr h left join 
mm4r4lib.trfdtl d on h.TRFBCH = d.TRFBCH
where h.TRFIDT >=''220408'' ' )

-->= varchar_format (current date -90 days, ''YYMMDD'') order by h.TRFIDT')

/**********************************************************Inserts into production*******************************************************/
insert into Reference.dbo.TRFDTL (
Transfer_Batch, From_Warehouse,To_Warehouse,sku_number,Vendor_Number,Dept,SDept,
Class,SClass,Qty_Requested,Qty_Shipped,Qty_Received,Qty_Allocated,Substitute_Number,
Sub_Code,Received_Warehouse,Unit_Cost,Retail_In,Retail_Out,Cube,Vendors_Number,Transfer_Status,
Transfer_Type,Transfer_Priority,Warehouse_Cycle,Schedule_Number,Schedule_Seq,Schedule_Name,
Style_Vendor,Style_Number,Color,Size,Dimension,Discrepancy_Flag,Cartor_Ship_Qty,Carton_Receive_Qty,
Weight
)

Select TRFBCH as Transfer_Batch, TRFFLC as From_Warehouse, TRFTLC as To_Warehouse, INUMBR as sku_number, 
ASNUM as Vendor_Number, IDEPT as Dept, ISDEPT as SDept, ICLAS as Class, ISCLAS as SClass, 
TRFREQ as Qty_Requested, TRFSHP as Qty_Shipped, TRFREC as Qty_Received, TRFALC as Qty_Allocated, 
TRFSUB asSubstitute_Number, TRFSCD as Sub_Code, TRFRLC as Received_Warehouse, TRFCST as Unit_Cost, 
TRFRIN as Retail_In, TRFROU as Retail_Out, ICUBE as Cube, IVNDP# as Vendors_Number, TRFSTS as Transfer_Status,
TRFTYP as Transfer_Type, TRFPTY as Transfer_Priority, TDCYCL as Warehouse_Cycle, TDSCWV as Schedule_Number, 
TDSCSQ as Schedule_Seq, TDSCNM as Schedule_Name, TRSVND as Style_Vendor, TRSTYL as Style_Number, TRSCOL as Color, 
TRSSIZ as Size, TRSDIM as Dimension, TRFDSP as Discrepancy_Flag, TDSCQT as Cartor_Ship_Qty, TDRCQT as Carton_Receive_Qty, 
TDWGHT  as Weight 
from Staging.dbo.tmp_TRFDTL st left join
Reference.dbo.TRFDTL p on st.TRFBCH = p.Transfer_Batch
where p.Transfer_Batch is null

/**********************************Updates table for the last 90 days that was pulled from as400*********************************/
update p
set
p.Qty_Requested = TRFREQ,
p.Qty_Shipped = TRFSHP,
p.Qty_Received = TRFREC,
p.Qty_Allocated = TRFALC,
p.Transfer_Status = TRFSTS,
p.Transfer_Type = TRFTYP,
p.Transfer_Priority = TRFPTY,
p.Cartor_Ship_Qty = TDSCQT,
p.Carton_Receive_Qty = TDRCQT
from Staging.dbo.tmp_TRFDTL st inner join
Reference.dbo.TRFDTL p on st.TRFBCH = p.Transfer_Batch


/****************************************************Truncate staging table*****************************************************/
truncate table staging.dbo.tmp_TRFHDR
truncate table Staging.dbo.tmp_TRFDTL

END

GO
