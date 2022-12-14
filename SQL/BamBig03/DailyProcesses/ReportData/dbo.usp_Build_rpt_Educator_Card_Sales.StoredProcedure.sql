USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_Educator_Card_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_rpt_Educator_Card_Sales]
as
--
declare @sd smalldatetime
declare @ed smalldatetime
--
select @sd = '04-30-2007'
select @ed = dateadd(ww,1,@sd)
--
Create Table #tmp2
(
Month			int,
Store_Number	int,
SLSD			Money
)
--
while @sd < getdate()
begin
--
select  datepart(mm,@sd) as Month,
		t1.store_number,
		sum(t1.Transaction_Amount) as SLSD
into	#tmp1
from	dssdata.dbo.header_transaction t1 
		inner join reference.dbo.educator_cards t2
on		t1.customer_number = t2.MCustNum 
where	t1.day_date >= @sd and t1.day_date < @ed
group by datepart(mm,t1.day_date),
		 t1.store_number
order by t1.store_number
--
insert into #tmp2
select	datepart(mm,@sd) as Month,
		t2.store_number,
		isnull(t1.SLSD,0) as SLSD
from	#tmp1 t1 right join reference.dbo.active_stores t2
on		t2.store_number = t1.store_number
order by t2.store_number
--
drop table #tmp1
--
select @sd = dateadd(mm,1,@sd)
select @ed = dateadd(mm,1,@ed)
end
--
drop table reportdata.dbo.rpt_educator_card_sales
--
SELECT store_number,	[10] AS Mo10, [11] AS Mo11, [12] AS Mo12, [1] AS Mo1, 
						[2] AS Mo2, [3] AS Mo3, [4] AS Mo4, [5] AS Mo5, 
						[6] as Mo6, [7] as Mo7, [8] as Mo8, [9] as Mo9
into reportdata.dbo.rpt_educator_card_sales
FROM 
(SELECT store_number, Month, SLSD
FROM #tmp2) p
PIVOT
(
sum(SLSD)
FOR Month IN
( [10], [11], [12], [1], [2], [3], [4], [5], [6], [7], [8], [9] )
) AS pvt
ORDER BY store_number


select store_number, Mo5 from reportdata.dbo.rpt_educator_card_sales


GO
