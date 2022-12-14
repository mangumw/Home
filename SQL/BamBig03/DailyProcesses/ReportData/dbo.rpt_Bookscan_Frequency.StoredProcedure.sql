USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Bookscan_Frequency]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rpt_Bookscan_Frequency]
as
--
select	isbn,
		Title,
		ltrim(str(yearnumber)) + staging.dbo.fn_leftpad(ltrim(str(weeknumber)),2) as period
into	#isbns
from	bookscan
where	ltrim(str(yearnumber)) + staging.dbo.fn_leftpad(ltrim(str(weeknumber)),2) > '200724'
order by yearnumber,weeknumber
--
select	isbn,
		Title,
		count(isbn) as Weeks
from	#isbns
group by isbn,Title

drop table #isbns

GO
