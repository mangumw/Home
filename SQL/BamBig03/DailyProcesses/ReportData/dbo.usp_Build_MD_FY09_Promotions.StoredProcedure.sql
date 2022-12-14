USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_MD_FY09_Promotions]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_MD_FY09_Promotions]
as
declare @start_date smalldatetime
declare @end_date smalldatetime
select @start_date = '04/26/2008'
select @end_date = staging.dbo.fn_dateonly(getdate())
--
-- get how many customers renewed card
--
select	t1.day_date,
		t1.store_number,
		count(t2.mcustnum) as Renewed
into	#Renewals
from	dssdata.dbo.club_card_activity t1,
		reference.dbo.md_fy09_customers t2
where	t1.day_date >= @start_date
and		t1.customer_number = t2.mcustnum
group by t1.day_date,t1.store_number
--
-- Get total transaction average from customer list
--
select	t3.day_date,
		t3.store_number,
		t3.Transaction_number,
		t3.register_number,
		sum(t2.extended_Price) as SLSD
into	#DetPrice
from	reference.dbo.md_fy09_customers t1,
		dssdata.dbo.detail_transaction_period t2,
		dssdata.dbo.header_transaction t3
where	t3.customer_number = t1.mcustnum
and		t3.day_date >= @start_date
and		t2.day_date = t3.day_date
and		t2.store_number = t3.store_number
and		t2.register_nbr = t3.register_number
and		t2.transaction_nbr = t3.transaction_number
group by t3.day_date,t3.store_number,t3.transaction_number,t3.register_number
--
select	t1.day_date,
		t1.Store_number,
		Avg(SLSD) as AvPrice
into	#AvPrice
from	#DetPrice t1
group by t1.day_date,t1.store_number
--
-- Get number of new emails
--
select	t2.day_date,
		t2.store_number,
		count(t3.mcustnum) as NewEmails
into	#NewEmails
from	reference.dbo.md_fy09_customers t1,
		dssdata.dbo.club_card_activity t2,
		dssdata.dbo.gclu t3
where	t2.day_date >= @start_date
and		t2.customer_number = t1.mcustnum
and		t1.email = ''
and		t3.mcustnum = t2.customer_number
and		t3.email != ''
group by t2.day_date,t2.store_number
--
-- GEt Num Trans and Avg from Promotion 1
--
select	t3.day_date,
		t3.store_number,
		t3.Transaction_number,
		t3.register_number
into	#DetPromo1
from	reference.dbo.md_fy09_customers t1,
		dssdata.dbo.detail_transaction_history t2,
		dssdata.dbo.header_transaction t3
where	t3.customer_number = t1.mcustnum
and		t3.day_date >= @start_date
and		t2.day_date = t3.day_date
and		t2.store_number = t3.store_number
and		t2.register_nbr = t3.register_number
and		t2.transaction_nbr = t3.transaction_number
and		t2.sku_number in (2252600,2252598)
and		t2.extended_price < 1.00
group by t3.day_date,t3.store_number,t3.transaction_number,t3.register_number
--
select	t1.day_date,
		t1.Store_number,
		sum(t2.Extended_price) as Ext_Price
into	#Transtot1
from	#DetPromo1 t1,
		dssdata.dbo.detail_transaction_history t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number
--
select	distinct
		t1.day_date,
		t1.Store_number,
		count(distinct t2.transaction_nbr) as NumTrans
into	#Transtot1a
from	#DetPromo1 t1,
		dssdata.dbo.detail_transaction_history t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number
--
select t1.day_date,
		t1.store_number,
		t2.NumTrans,
		avg(t1.Ext_Price) as Av_Price
into	#AvgPromo1
from	#Transtot1 t1,
		#transtot1a t2
where	t2.day_date = t1.day_date and t2.store_number = t1.store_number
group by t1.day_date,t1.store_number,t2.numtrans
order by store_number
--
-- GEt Num Trans and Avg from Promotion 2
--
select	t3.day_date,
		t3.store_number,
		t3.Transaction_number,
		t3.register_number
into	#DetPromo2
from	reference.dbo.md_fy09_customers t1,
		dssdata.dbo.detail_transaction_history t2,
		dssdata.dbo.header_transaction t3
where	t3.customer_number = t1.mcustnum
and		t3.day_date >= @start_date
and		t2.day_date = t3.day_date
and		t2.store_number = t3.store_number
and		t2.register_nbr = t3.register_number
and		t2.transaction_nbr = t3.transaction_number
and		t2.sku_number in (2252600,2252598)
and		t2.extended_price > 2.95 and t2.extended_price < 6.00
group by t3.day_date,t3.store_number,t3.transaction_number,t3.register_number
--
select	t1.day_date,
		t1.Store_number,
		sum(t2.Extended_price) as Ext_Price
into	#Transtot2
from	#DetPromo2 t1,
		dssdata.dbo.detail_transaction_history t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number
--
select	distinct
		t1.day_date,
		t1.Store_number,
		count(distinct t2.transaction_nbr) as NumTrans
into	#Transtot2a
from	#DetPromo2 t1,
		dssdata.dbo.detail_transaction_history t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number
--
select t1.day_date,
		t1.store_number,
		t2.NumTrans,
		avg(t1.Ext_Price) as Av_Price
into	#avgpromo2
from	#Transtot2 t1,
		#transtot2a t2
where	t2.day_date = t1.day_date and t2.store_number = t1.store_number
group by t1.day_date,t1.store_number,t2.numtrans
order by store_number
--
-- Build final table
truncate table reportdata.dbo.MD_FY09_Promo
insert into reportdata.dbo.MD_FY09_Promo
select	t1.Day_Date,
		t2.store_number,
		t2.store_name,
		0 as Renewals,
		0 as Transaction_Avg,
		0 as New_Emails,
		0 as Promo1_Trans,
		0 as Promo1_Avg,
		0 as Promo2_Trans,
		0 as Promo2_avg
from	reference.dbo.calendar_dim t1,
		reference.dbo.active_stores t2
where	t1.day_date >= @start_date
and		t1.day_date <= @end_date
--
update reportdata.dbo.MD_FY09_Promo
set Renewals = #renewals.renewed
from #renewals
where reportdata.dbo.MD_FY09_Promo.Day_Date = #Renewals.day_date
and reportdata.dbo.MD_FY09_Promo.store_number = #Renewals.store_number
--
update reportdata.dbo.MD_FY09_Promo
set Transaction_Avg = #AvPrice.AvPrice
from #Avprice
where reportdata.dbo.MD_FY09_Promo.Day_Date = #AvPrice.day_date
and reportdata.dbo.MD_FY09_Promo.store_number = #AvPrice.store_number
--
update reportdata.dbo.MD_FY09_Promo
set New_Emails = #NewEMails.NewEMails
from #NewEmails
where reportdata.dbo.MD_FY09_Promo.Day_Date = #NewEmails.day_date
and reportdata.dbo.MD_FY09_Promo.store_number = #NewEMails.store_number
--
update reportdata.dbo.MD_FY09_Promo
set Promo1_Trans = #AvgPromo1.Numtrans,Promo1_Avg = #AvgPromo1.Av_Price
from #AvgPromo1
where reportdata.dbo.MD_FY09_Promo.Day_Date = #AvgPromo1.day_date
and reportdata.dbo.MD_FY09_Promo.store_number = #AvgPromo1.store_number
--
update reportdata.dbo.MD_FY09_Promo
set Promo2_Trans = #AvgPromo2.Numtrans,Promo2_Avg = #AvgPromo2.Av_Price
from #AvgPromo2
where reportdata.dbo.MD_FY09_Promo.Day_Date = #AvgPromo2.day_date
and reportdata.dbo.MD_FY09_Promo.store_number = #AvgPromo2.store_number
--
--drop table #Renewals
--drop table #detprice
--drop table #AvPrice
--drop table #NewEmails
--Drop table #DetPromo1
--drop table #DetPromo2
--drop table #AvgPromo1
--drop table #avgpromo2
--drop table #Transtot1
--drop table #Transtot1a
--drop table #transtot2
--drop table #transtot2a

GO
