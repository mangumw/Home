USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Publisher_Scorecard_YTD]    Script Date: 9/22/2022 1:59:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









ALTER procedure [dbo].[usp_Build_Publisher_Scorecard_YTD]
as
--
-- This is the build proc for the Publisher_YTD_Scorecard
-- This report will show, by publisher the following information:
--	Purchases YTD, Purchases Last YTD, Returns YTD, Returns Last YTD
--	Sales YTD, Sales Last YTD, Owned TY, Owned LY, Co-Op TY, Co-Op LY
-- The report will be deployed to the Report Server on BamBig02.
--
--
-- Declare Variables Needed   

--
declare @pub			varchar(6)
declare @Buyer			varchar(3)
declare	@Purchases_TY	Money
declare @Purchases_LY	Money
declare @Returns_TY		Money
declare @Returns_LY		Money
declare @Sales_TY		Money
declare @Sales_LY		Money
declare @Inv_LY			Money
declare @Inv_TY			Money
declare @CoOp_TY		Money
declare @CoOp_LY		Money
declare @New_CoOp_TY		Money
declare @New_CoOp_LY		Money
declare @startdate smalldatetime
declare @enddate smalldatetime
declare @rcpt_start smalldatetime

--
-- Insert any vendors not in the groups file
--
insert into reference.dbo.Scorecard_Pubs_Groups2 
select pubname, pubcode from reference.dbo.publisher 
where pubcode not in (select pub from reference.dbo.Scorecard_Pubs_Groups2)

--
-- Get all pub codes
--
select	distinct PubCode,
		Buyer
into #pubs 
from	reference.dbo.publisher
where pubcode > ''
order by pubcode

--
-- Setup the date variables for the procedure 
--

--
-- Get the fiscal information first.
--
declare @fiscal_year int
declare @fiscal_Period int
select @fiscal_year = 2017
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @Fiscal_Period = fiscal_period - 1 from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
--
-- If calculated fiscal period = 0, use last period from previous year
--
if @Fiscal_Period = 0
begin
	set @Fiscal_Period = 12
	set @fiscal_year = @fiscal_year - 1
end
--
-- Get date range (YTD)
--
select @startdate = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = 1
select @enddate = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @rcpt_start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
--
-- Remove any records past the beginning of the period being looked at.  Insert updated records from ZRFRCVQ
--
delete from reference.dbo.Receipt_Tracking where Day_Date >= @rcpt_start

insert into reference.dbo.receipt_tracking
select newday, rqpono, rqvnno, rqitno, rqwhse, rqcost, rqsprc, rqqtyp, rqqtyr 
from reference.dbo.zrfrcvq
where newday >= @rcpt_start

--
-- Clear out the table and put in empty rows for each pub
--
truncate table dssdata.dbo.Publisher_Scorecard_YTD
--
insert into dssdata.dbo.Publisher_Scorecard_YTD
select	@Fiscal_Year,
		@Fiscal_Period,
		PubCode,
		Buyer,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		getdate()
from	#Pubs
--
-- Get This Year date variables.
--
declare @TY_Start		smalldatetime
declare @TY_Start_Int	int
declare @TY_End			smalldatetime
declare @TY_End_Int		int
--
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @TY_Start_Int = staging.dbo.fn_DateToInt(@TY_Start)
select @TY_End = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @TY_End_Int = staging.dbo.fn_DateToInt(@TY_End)
--
-- Get Last Year date variables.
--
declare @LY_Start smalldatetime
declare @LY_Start_Int int
declare @LY_End smalldatetime
declare @LY_End_Int int

declare @fiscal_year_ytd int
declare @fiscal_period_start int
--
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year - 1
select @LY_Start_Int = staging.dbo.fn_DateToInt(@LY_Start)
select @LY_End = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year - 1 and fiscal_period = @fiscal_period
select @LY_End_Int = staging.dbo.fn_DateToInt(@LY_End)


--JL 20210203 - Move from BAMITR08 to BAMBIG03 due to connection issues during loop processing
truncate table reference.dbo.CoOp_TY
if @fiscal_period < 12
BEGIN
insert into reference.dbo.CoOp_TY
SELECT	t1.PubCode as PubCode,
		isnull(Sum(t2.ClaimAmount),0) as ClaimAmount
FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
ON		t2.contractid = t1.contractid
WHERE   (t2.claimmonth between 2 and @fiscal_period + 1 and t2.claimyear = @fiscal_year - 1)
group by t1.PubCode
END;
else
BEGIN
insert into reference.dbo.CoOp_TY
SELECT	t1.PubCode as PubCode,
		isnull(Sum(t2.ClaimAmount),0) as ClaimAmount
FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
ON		t2.contractid = t1.contractid
WHERE   (t2.claimmonth between 2 and @fiscal_period + 1 and t2.claimyear = @fiscal_year - 1) or (t2.claimmonth = 1 and t2.claimyear = @fiscal_year)
group by t1.PubCode
END;


truncate table reference.dbo.CoOp_LY
if @fiscal_period < 12
BEGIN
insert into reference.dbo.CoOp_LY
SELECT	t1.PubCode as PubCode,
		isnull(Sum(t2.ClaimAmount),0) as ClaimAmount
FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
ON		t2.contractid = t1.contractid
WHERE   (t2.claimmonth between 2 and @fiscal_period + 1 and t2.claimyear = @fiscal_year - 2)
group by t1.PubCode
END;
else
BEGIN
insert into reference.dbo.CoOp_LY
SELECT	t1.PubCode as PubCode,
		isnull(Sum(t2.ClaimAmount),0) as ClaimAmount
FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
ON		t2.contractid = t1.contractid
WHERE   (t2.claimmonth between 2 and @fiscal_period + 1 and t2.claimyear = @fiscal_year - 2) or (t2.claimmonth = 1 and t2.claimyear = @fiscal_year - 1)
group by t1.PubCode
END;

--
-- Set up loop to go through all pubs
--
declare cur cursor for select pubcode,Buyer from #pubs
open cur
fetch next from cur into @pub,@Buyer
while @@fetch_status = 0
begin
--
-- Clear out variables
--
select @Purchases_TY = 0
select @Purchases_LY = 0
select @Returns_TY = 0
select @Returns_LY = 0
select @Sales_TY = 0
select @Sales_LY = 0
select @CoOp_TY = 0
select @CoOp_LY = 0
select @New_CoOp_TY = 0
select @New_CoOp_LY = 0
select @Inv_TY = 0
select @inv_LY = 0
--
-- For this query, the dates will run from @TY_Start to @TY_End, @LY_Start to @LY_End
-- End of Date Processing. Start building temp tables with the output data.
--
--
-- Get the Current Year Purchases from Receipt Tracking
--
select	@Purchases_TY = isnull(sum(t1.Unit_Cost * t1.Rec_Qty),0) 
from	reference.dbo.Receipt_Tracking t1,
		reference.dbo.itmst t2
where	t1.Day_Date >= @TY_Start
and		t1.Day_Date <= @TY_End
and		t2.pubcode = @pub
and		t1.ISBN = t2.ISBN
--
--
-- Get purchases last year from reference.dbo.Receipt_Tracking
--
select	@Purchases_LY = isnull(sum(t1.Unit_Cost * t1.Rec_Qty),0) 
from	reference.dbo.Receipt_Tracking t1,
		reference.dbo.itmst t2
where	t1.Day_Date >= @LY_Start
and		t1.Day_Date <= @LY_End
and		t2.pubcode = @pub
and		t1.ISBN = t2.ISBN
--
-- Get returns this year from reference.dbo.RCPT
-- We have to use the _Int versions of the dates because the tables holds the dates as integers
-- Returns are identified by a prefix of R in the PO Number (PO_Number)
--
select	@Returns_TY = isnull(sum(abs(Invoice_Cost)),0)
from	reference.dbo.RCPT t1,
		reference.dbo.itmst t2
where	t1.Receipt_Date >= @TY_Start
and		t1.Receipt_Date <= @TY_End
and		t1.PO_Number like 'R%'
and		t2.PubCode = @pub
and		t2.isbn = t1.item_number
--
-- Get the returns for last year
--
select	@Returns_LY = isnull(sum(abs(Invoice_Cost)),0)
from	reference.dbo.RCPT t1,
		reference.dbo.itmst t2
where	t1.Receipt_Date >= @LY_Start
and		t1.Receipt_Date <= @LY_End
and		t1.PO_Number like 'R%'
and		t2.PubCode = @pub
and		t2.isbn = t1.item_number
--
-- Get the sales for this year
--
select	@Sales_TY = isnull(sum(t1.Current_Dollars),0)
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_master t2
where	day_date >= @TY_Start
and		day_date <= @TY_End
and		t2.pubcode = @pub
and		t1.sku_number = t2.sku_number
group by t2.pubcode
--
-- Get last year sales
--
select	@Sales_LY = isnull(sum(t1.Current_Dollars),0)
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_master t2
where	day_date >= @LY_Start
and		day_date <= @LY_End
and		t2.pubcode = @pub
and		t1.sku_number = t2.sku_number
group by t2.pubcode


--JL 20210203 - Move from BAMITR08 to BAMBIG03 due to connection issues
SELECT	@CoOp_TY = ClaimAmount
FROM	reference.dbo.CoOp_TY
where   PubCode = @pub


SELECT	@CoOp_LY = ClaimAmount
FROM	reference.dbo.CoOp_LY
where   PubCode = @pub


--SELECT	@CoOp_TY = 
-- isnull(Sum(t2.ClaimAmount),0)
--FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
--ON		t2.contractid = t1.contractid
--where   t1.PubCode = @pub
--and     t2.claimmonth
--between 2 and  @fiscal_period +1
--and		t2.claimyear =  @fiscal_year - 1


--SELECT	@CoOp_LY = isnull(Sum(t2.ClaimAmount),0)
--FROM	BAMITR08.CoOpApp.dbo.Contracts t1 INNER JOIN BAMITR08.CoOpApp.dbo.Contractclaim t2
--ON		t2.contractid = t1.contractid
--where   t1.PubCode = @pub
--and     t2.claimmonth between 2 and  @fiscal_period +1
--and		t2.claimyear = @fiscal_year - 2


--JL 20210127 - Temporary table used as POMCOOVD/POMCOOVH were previously purging each month and did not have the expected history data
--SELECT	@New_CoOp_TY = 
--  ABS(isnull(Sum(t1.PUCOPA),0))
--FROM	[BKL400].[BKL400].[MM4R4LIB].[POMCOO5] t1
--WHERE	t1.PUPUBA = @pub


SELECT	@New_CoOp_TY = ABS(isnull(Sum(t1.VDCAMT),0))
FROM	[BKL400].[BKL400].[MM4R4LIB].[POMCOOVD] t1 INNER JOIN [BKL400].[BKL400].[MM4R4LIB].[POMCOOVH] t2
ON		t2.VHCONT = t1.VDCONT
where   t2.VHPUBC = @pub
and     t1.VDMONT between 1 and @fiscal_period
and		t1.VDYEAR = @fiscal_year - 2000


SELECT	@New_CoOp_LY = ABS(isnull(Sum(t1.VDCAMT),0))
FROM	[BKL400].[BKL400].[MM4R4LIB].[POMCOOVD] t1 INNER JOIN [BKL400].[BKL400].[MM4R4LIB].[POMCOOVH] t2
ON		t2.VHCONT = t1.VDCONT
where   t2.VHPUBC = @pub
and     t1.VDMONT between 1 and @fiscal_period
and		t1.VDYEAR = @fiscal_year - 2001


----
-- Get the inventory from CARD_History for this year
--
select @Inv_TY = sum(t1.retail * t1.Total_OnHand)
				from dssdata.dbo.card_history t1,
				reference.dbo.item_Master t2
				where t2.pubcode = @pub
				and t1.sku_number = t2.sku_number
				and day_date = dateadd(dd,1,@TY_End)
--
-- Get the inventory from CARD_History for Last Year
--
select @Inv_LY = isnull(sum(t1.retail * t1.Total_OnHand),0)
				from dssdata.dbo.card_history t1,
				reference.dbo.item_Master t2
				where t2.pubcode = @pub
				and t1.sku_number = t2.sku_number
				and day_date = dateadd(dd,1,@LY_End)
--
-- Combine above tmp tables into the report output table
--
Update	dssdata.dbo.Publisher_Scorecard_YTD
set		Purchases_TY = @Purchases_TY,
		Purchases_LY = @Purchases_LY,
		Returns_TY = @Returns_TY,
		Returns_LY = @Returns_LY,
		Sales_TY = @Sales_TY,
		Sales_LY = @Sales_LY,
		CoOp_TY = @CoOp_TY + @New_CoOp_TY,
		CoOp_LY = @CoOp_LY + @New_CoOp_LY,
		--New_CoOp_TY = @New_CoOp_TY,
 		--New_CoOp_LY = @New_CoOp_LY,
		Inv_TY = @Inv_TY,
		Inv_LY = @Inv_LY
where	Pub_Code = @Pub
--
-- Loop to get next pub
--
fetch next from cur into @pub,@Buyer
end
--
-- Cleanup
--
close cur
deallocate cur
drop table #pubs
--
-- now, populate the Publisher_Scorecard_YTD_PubGrp table
-- by summing the Publisher_Scorecard_YTD by Publisher Group
--
truncate table dssdata.dbo.Publisher_Scorecard_YTD_PubGrp
insert into dssdata.dbo.Publisher_Scorecard_YTD_PubGrp
select	t2.fiscal_year,
		t2.fiscal_period,
		t1.Vendor,
		NULL,
		sum(t2.purchases_ty) as Purchases_TY,
		sum(t2.Purchases_LY) as Purchases_LY,
		sum(t2.Returns_ty) as Returns_TY,
		sum(t2.Returns_LY) as Returns_LY,
		sum(t2.Sales_ty) as Sales_TY,
		sum(t2.Sales_LY) as Sales_LY,
		sum(t2.CoOp_ty ) as CoOp_TY,
		sum(t2.CoOp_LY ) as CoOp_LY,
		sum(t2.Inv_ty) as Inv_TY,
		sum(t2.Inv_LY) as Inv_LY,
		getdate()
from	reference.dbo.Scorecard_Pubs_Groups2 t1,
		dssdata.dbo.Publisher_Scorecard_YTD t2
where	t2.pub_Code=t1.pub
group by t2.fiscal_year,t2.fiscal_period,t1.vendor
order by t1.vendor









