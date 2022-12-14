USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateStoreInformation]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/15/2021
-- Description: Migrated from SSIS to SP; Active Stores
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateStoreInformation] 

AS
BEGIN
	SET NOCOUNT ON;
/***********************************************************Truncate Staging Tables****************************************************/
truncate table staging.dbo.tmp_invadi;
truncate table staging.dbo.tmp_TblDst;
truncate table staging.dbo.tmp_TblReg;
truncate table TblStr;


/*************************************************************Migrate as400 tables for Active Stores*********************************************************/
insert into TblStr
select STRNUM, STRNAM, STADD1, STADD2, STADD3, STCITY, STPVST, STCNTY, STCTRY, STZIP, STPHON, STFAXN, STSHRT, REGNUM, STMNGR,
STSCEN, STSDAT, STRETL, STPOLL, STSNDY, STRHDO, STBACT, STRWHS, STRDST, STRCMP, STRTYP, STOUTQ, STCOMP, STCNTR, STGLYN,
STAPYN, STARYN, STLCN#, ZONNUM, STAVGC, STSCLK, STMSTK, STAYES, STAFCT, RPLZN, STPRMS, STRPON, STCLCN, STCLDT, STFACT,
STBANK, SAN# from openquery (bkl400, 'Select STRNUM, STRNAM, STADD1, STADD2, STADD3, STCITY, STPVST, STCNTY, STCTRY, STZIP, STPHON, STFAXN, STSHRT, REGNUM, STMNGR,
STSCEN, STSDAT, STRETL, STPOLL, STSNDY, STRHDO, STBACT, STRWHS, STRDST, STRCMP, STRTYP, STOUTQ, STCOMP, STCNTR, STGLYN,
STAPYN, STARYN, STLCN#, ZONNUM, STAVGC, STSCLK, STMSTK, STAYES, STAFCT, RPLZN, STPRMS, STRPON, STCLCN, STCLDT, STFACT,
STBANK, SAN# from MM4R4LIB.TBLSTR');

insert into staging.dbo.tmp_TblDst
select STRDST, DSTNAM, DSTSHT, REGNUM from openquery (bkl400, 'Select STRDST, DSTNAM, DSTSHT, REGNUM from MM4R4LIB.TBLDST');

insert into staging.dbo.tmp_TblReg
select REGNUM, REGNAM, REGMGR, REGPHN, REGSHT from openquery (bkl400, 'Select REGNUM, REGNAM, REGMGR, REGPHN, REGSHT from MM4R4LIB.TBLREG');

insert into staging.dbo.tmp_invadi
select  ADINUM, STRNUM from openquery (bkl400, 'Select  ADINUM, STRNUM from MM4R4LIB.INVADI');

truncate table reference.dbo.district_dim;

insert into reference.dbo.district_dim
select	regnum as region_number, strdst as district_number,	dstnam as district_name, dstsht as district_short_name, getdate() as record_date
from	staging.dbo.tmp_tbldst;


truncate table reference.dbo.region_dim;

insert into reference.dbo.region_dim
select	regnum as region_number, regnam as region_name,	regsht as region_short_name, getdate() as record_date
from	staging.dbo.tmp_tblreg;


truncate table reference.dbo.Store_Dim;

insert into reference.dbo.Store_Dim
select	0 as Store_Group_Number, t1.strnum, t1.strnam, t1.stmstk, t1.strdst, t1.stadd1, t1.stadd2, t1.stcity,
t1.stpvst, t1.stcnty, t1.stctry, t1.stzip, t1.stphon,
staging.dbo.fn_IntToDate(t1.stsdat) as Date_Opened,
staging.dbo.fn_IntToDate(t1.stcldt) as Date_Closed,
getdate() as Record_Date
from	reference.dbo.tblstr t1
order by t1.strnum;


/******************************************************Updating Store Group number in Stores table*************************************/
update reference.dbo.store_dim 
set Store_Group_Number = 29 
where store_number in 
(select strnum from staging.dbo.tmp_invadi
where staging.dbo.tmp_invadi.adinum = 29);


truncate table reference.dbo.active_stores;

exec staging.dbo.usp_build_active_stores
END
GO
