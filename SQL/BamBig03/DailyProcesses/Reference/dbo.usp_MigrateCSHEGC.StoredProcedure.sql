USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateCSHEGC]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 08/20/2021
-- Description:	re-write to migrating CSHEGC table from DB2 (as400)
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateCSHEGC] 

AS
BEGIN
	--SET NOCOUNT ON;

/**********************************************migrate table from as400 into staging database************************************************************/
Insert into staging.dbo.tmp_CSHEGC (
EGSTOR, EGDATE, [EGREG#], EGROLL, [EGTRN#],
[EGSEQ#], EGDTYP, EGEXTA, EGGCNM, EGGCAC, EGCDTE, EGPRGM
)

Select EGSTOR, EGDATE, [EGREG#], EGROLL, [EGTRN#],
[EGSEQ#], EGDTYP, EGEXTA, EGGCNM, EGGCAC, EGCDTE, EGPRGM  
from openquery (BKL400,'Select EGSTOR, EGDATE, EGREG#, EGROLL, EGTRN#,
EGSEQ#, EGDTYP, EGEXTA, EGGCNM, EGGCAC, EGCDTE, EGPRGM 
from mm4r4lib.cshegc
where egdate >= varchar_format (current date -7 days, ''YYYYMMDD'') order by egcdte')
/************************************************Insert into Reference production table from staging database*********************************************/
insert into Reference.dbo.CSHEGC
(Store_Number,
Day_Date,
Register_Number,
Roll_Over,
Transaction_Number,
Sequence_Number,
Transaction_Type,
Extended_Amount,
Gift_Card_Number,
GC_Auth_Code,
Date_Created,
Program_Name
)
/***Has to join on Store Number, Register Number, Transaction Number, Transaction Type, and Extended amount for all unique fields***/
select Distinct EGSTOR as Store_Number, cast(cast(EGDATE as varchar(8)) as Date) as Day_Date, EGREG# as Register_Number, EGROLL as Roll_Over, EGTRN# as Transaction_Number,
EGSEQ# as Sequence_Number, EGDTYP as Transaction_Type, EGEXTA as Extended_Amount, EGGCNM as Gift_Card_Number, EGGCAC as GC_Auth_Code, 
EGCDTE as Date_Created, EGPRGM as Program_Name
from staging.dbo.tmp_CSHEGC st left join
Reference.dbo.CSHEGC p on st.EGSTOR = p.Store_Number and st.EGREG# = p.Register_Number and st.EGTRN# = p.Transaction_Number and 
st.EGDTYP = p.Transaction_Type and st.EGEXTA = p.Extended_Amount
where p.Transaction_Number is null
order by st.EGSTOR, st.EGTRN#

/**********************************************************Updates last 6 prior days for Changes************************************************************/
update p
set p.Store_Number = EGSTOR, p.day_date = cast(cast(EGDATE as varchar(8)) as Date), p.Register_Number = [EGREG#], p.Roll_Over = EGROLL, p.Transaction_Number = [EGTRN#],
p.Sequence_Number = [EGSEQ#], p.Transaction_Type = EGDTYP, p.Extended_Amount = EGEXTA, p.Gift_Card_Number = EGGCNM, p.GC_Auth_Code = EGGCAC, 
p.Date_Created = EGCDTE, p.Program_Name = EGPRGM  
--select p.*
from staging.dbo.tmp_CSHEGC st inner join
Reference.dbo.CSHEGC p on st.EGSTOR = p.Store_Number and st.EGREG# = p.Register_Number and st.EGTRN# = p.Transaction_Number and 
st.EGDTYP = p.Transaction_Type and st.EGEXTA = p.Extended_Amount
where p.Day_Date > DATEADD(DAY, -6, GETDATE())

/**********************************************************removes data from temp table********************************************************************/
truncate table staging.dbo.tmp_CSHEGC
END
GO
