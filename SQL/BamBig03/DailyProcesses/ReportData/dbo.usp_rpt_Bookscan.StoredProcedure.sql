USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Bookscan]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_rpt_Bookscan]
as
declare @Year int
declare @Week int
declare @Def_Share_Mult float
declare @SD smalldatetime
declare @ED smalldatetime

--
select @Year = max(yearnumber) from reference.dbo.bookscan
select @week = max(weeknumber) from reference.dbo.bookscan 
               where YearNumber = @Year
--
select @SD = dateadd(dd,+1,staging.dbo.fn_Last_Saturday(getdate()))
select @ED = dateadd(dd,6,@SD)
--
select @Def_Share_Mult = Share_Mult from reference.dbo.Expected_Market_Share where Binding_Code = 'Default'
--
Truncate table staging.dbo.BS1
Truncate table staging.dbo.BS2
--
insert into staging.dbo.BS1
select	Rank () OVER (order by t1.Week_Units desc ) as Rank,
		t2.SDept_Name,
		t2.ISBN,
		t1.ISBN as Bookscan_ISBN,
		t1.Title,
		t1.Author,
		t1.Imprint,
		t1.Publisher,
		t1.PubDate,
		t1.BISACCAT,
		t1.H,
		t1.Binding,
		isnull(t3.Share_Mult,@def_Share_Mult) as Share_Mult,
		t1.Retail_Price/100 as Price,
		t1.Week_Units as Bookscan_Week,
		t2.Week1Units as WeekBam,
		0 as Net_SLS,
		t2.Week1Units as Bam_SLS_TTL,
		0 as Exp_Share,
		t2.Bam_OnHand,
		t2.InTransit,
		t2.Warehouse_OnHand,
		t2.Qty_OnOrder,
		t4.BAM_OnHand as LW_BAM_OnHand,
		t4.Warehouse_OnHand as LW_Warehouse_OnHand,
		t4.Qty_OnOrder as LW_Qty_OnOrder,
		0 as Inv_Change,
		t2.Dept,
		t2.Buyer
from	reference.dbo.Bookscan t1 
left join dssdata.dbo.CARD t2 
on		t2.EAN = t1.ISBN
left join reference.dbo.Expected_Market_Share t3
on		t3.Binding_Code = t1.Binding
left join dssdata.dbo.CARD_History t4
on		t4.day_date = @SD 
and		t4.sku_number = t2.sku_number
where	t1.yearnumber = @year and t1.weeknumber = @Week
--
insert into staging.dbo.BS2
select	t1.ISBN,
		sum(current_Units) as NetSLS
from	staging.dbo.BS1 t1,
		dssdata.dbo.Internet_Weekly_Sales t2
where	t2.ISBN = t1.ISBN
and		t2.day_date >= @SD and t2.day_Date <= @ED
group by t1.isbn
--
update	staging.dbo.BS1
set		Exp_Share = Bookscan_Week * Share_Mult
--
update	staging.dbo.BS1 
set		staging.dbo.BS1.Net_SLS = staging.dbo.BS2.NetSLS,
		staging.dbo.BS1.BAM_SLS_TTL = staging.dbo.BS1.WeekBAM + staging.dbo.BS2.NetSLS
from	staging.dbo.BS2
where	staging.dbo.BS2.ISBN = staging.dbo.BS1.ISBN
--
update  staging.dbo.BS1
set		staging.dbo.bs1.Inv_Change = (Bam_OnHand+Qty_OnOrder) - (LW_Bam_OnHand + LW_Warehouse_OnHand + LW_Qty_OnOrder)
--
drop table reportdata.dbo.rpt_Bookscan_Report

select * 
into reportdata.dbo.rpt_bookscan_report
from staging.dbo.BS1
order by Bookscan_Week desc









GO
