USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Sales_by_ClubCardMember]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- Modified 9/29/04 to use GLCU for membership info instead of the member_fact table
-- Modified 1/26/05 to replace store 867 with store 575 - 867 closed
-- Modified 2/09/07 to use BAMBIG1 data and test all 3 expiration dates
Create PROCEDURE [dbo].[usp_Sales_by_ClubCardMember]
@MemberBegDate datetime
AS
--declare @MemberBegDate datetime --just for testing
--set @MemberBegDate = '11/1/2005' --just for testing
CREATE TABLE #tmpccsales
(MstoreNum varchar(5),
MCustNum decimal(11,0),
MCreateDate datetime,
PreMark1 varchar(30),
day_date datetime,
total_spent money
)								
								
-- get the members who join in the month of begindate
select gclu.MstoreNum,
	cast (gclu.MCustNum as decimal(11,0)) as MCustNum,
	gclu.MCreateDate, gclu.PreMark1
into #tmp_hold
from bambig1.DssData.dbo.GCLU gclu
--inner join datamart.cmndmdta.store_dim csd on csd.store_number = gclu.MstoreNum -- join not needed with GCLU
--where MstoreNum = '323' and
where MstoreNum in (111,216,400,409,412,476,486,512,516,560,575,591,628,661,748,749,833,923,949,955)
	and gclu.PclientType <> 'INS' -- excludes institutional customers
	and (
	(gclu.ExpDate1 - 365) >= @MemberBegDate and
	(gclu.ExpDate1 - 365) < dateadd(month,1,@memberbegdate)
	or
	(gclu.ExpDate2 - 365) >= @MemberBegDate and
	(gclu.ExpDate2 - 365) < dateadd(month,1,@memberbegdate)
	or
	(gclu.ExpDate3 - 365) >= @MemberBegDate and
	(gclu.ExpDate3 - 365) < dateadd(month,1,@memberbegdate)
	)

---replaced 176 with 628  for Oct, 2004 membership (176 closed 8/28/05)
	--gclu.MCreateDate >= @MemberBegDate
	--and gclu.MCreateDate < dateadd(month,1,@memberbegdate)
	
	--and gclu.PreMark1 <>'GOLD' (slows query)--exclude gold card members - they get  a free card 
	--is null statement did not work on BAMBIG1

begin
-- current year
	insert into #tmpccsales (MstoreNum, MCustNum, MCreateDate, PreMark1, day_date, total_spent)
	select th.MstoreNum,
		th.MCustNum,
		th.MCreateDate,
		th.PreMark1,
		day_date,
		sum(cht.transaction_amount)
	from bambig1.DssData.dbo.Header_Transaction cht
	--inner join bambig1.DssData.cmndmdta.store_dim csd on csd.store_record_number = cht.store_record_number
	inner join #tmp_hold th on th.MstoreNum = cht.Store_Number and
				th.MCustNum = cht.customer_number 
				
	where  cht.day_date >= @memberbegdate AND
			cht.day_date < DATEADD(yy, 1, @memberbegdate)
	group by th.MstoreNum, th.MCustNum, th.MCreateDate, th.PreMark1, cht.day_date
end

SELECT #tmpccsales.MstoreNum, #tmpccsales.day_date, #tmpccsales.total_spent, #tmpccsales.MCreateDate, MCustNum
FROM [#tmpccsales]
WHERE PreMark1 <>'GOLD' and 
MCustNum in (select MCustNum from #tmpccsales group by MCustNum having sum(total_spent) < 5000) -- restricts list to members spending less than a given $ limit
-- #tmpccsales.day_date >= @MemberBegDate
--AND #tmpccsales.day_date < dateadd(year,1,@MemberBegDate)




GO
