USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_rec_tracker]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_rec_tracker] as 

--select * from tmp_load.dbo.track_dte - not needed
--select * from tmp_load.dbo.track_dte2 - for reciepts
--select * from tmp_load.dbo.track_dte3 - for open order join with daynumber

--select * from tmp_load.dbo.track_plan - the planned receipts

-- select * from tmp_load.dbo.track_pln - date like integer with period - not needed i think


--- REC by period -----------------
truncate table staging.dbo.rec_track1
insert into staging.dbo.rec_track1

SELECT     SUM(Reference.dbo.Receipt_Tracking.Rec_Qty * Reference.dbo.Receipt_Tracking.Unit_Rtl / 1.95) AS TTL_Rec, Tmp_Load.dbo.track_dte2.period
FROM         Tmp_Load.dbo.track_dte2 INNER JOIN
                      Reference.dbo.Receipt_Tracking ON Tmp_Load.dbo.track_dte2.date = Reference.dbo.Receipt_Tracking.Day_Date
WHERE     (Reference.dbo.Receipt_Tracking.Day_Date BETWEEN CONVERT(DATETIME, '2011-01-31 00:00:00', 102) AND CONVERT(DATETIME, '2012-01-28 00:00:00', 102))
GROUP BY Tmp_Load.dbo.track_dte2.period
--- Open Orders by period ----------
truncate table staging.dbo.rec_track2
insert into staging.dbo.rec_track2
SELECT     Tmp_Load.dbo.track_dte3.period, SUM((Reference.dbo.POS.Qty_Ordered - ISNULL(Reference.dbo.POS.Qty_Received, 0)) * Reference.dbo.POS.Retail / 2) 
                      AS net_oo
FROM         Reference.dbo.POS INNER JOIN
                      Tmp_Load.dbo.track_dte3 ON Reference.dbo.POS.Due_Date = Tmp_Load.dbo.track_dte3.day_number
GROUP BY Tmp_Load.dbo.track_dte3.period
---- Join REC,OO,PLAN ----------------
truncate table staging.dbo.rec_track3
insert into staging.dbo.rec_track3
SELECT     t1.Period, t1.[Plan] AS rec_plan, ISNULL(t3.net_oo, 0) AS orders, ISNULL(t2.TTL_Rec, 0) AS receipts
FROM         Tmp_Load.dbo.track_plan AS t1 LEFT OUTER JOIN
                      Staging.dbo.rec_track2 AS t3 ON t1.Period = t3.period LEFT OUTER JOIN
                      Staging.dbo.rec_track1 AS t2 ON t1.Period = t2.period



--SELECT Period, rec_plan, orders, receipts, REC_plan - orders - receipts as over_under
--INTO staging.dbo.rec_track5
--FROM Staging.dbo.rec_track3
--
--SELECT     Period, rec_plan, orders, receipts, over_under
--FROM         Staging.dbo.rec_track5

truncate table staging.dbo.rec_track4
insert into staging.dbo.rec_track4
SELECT Period, 
            rec_plan, 
            orders, 
            receipts, 
            case 
              when Period LIKE 'old' 
                then 0 
             else rec_plan - orders - receipts 
            end as over_under
FROM Staging.dbo.rec_track3
------------- add old orders across board --------------------

truncate table staging.dbo.rec_track4_b
insert into staging.dbo.rec_track4_b

SELECT     Period, orders AS oldorders
FROM         Staging.dbo.rec_track4
WHERE     (Period = N'old') 
--------------- table with old orders for new case statement ----------------
truncate table staging.dbo.rec_track6
insert into staging.dbo.rec_track6
SELECT     Staging.dbo.rec_track4.Period, Staging.dbo.rec_track4.rec_plan, Staging.dbo.rec_track4.orders, Staging.dbo.rec_track4.receipts, Staging.dbo.rec_track4.over_under, 
                      Staging.dbo.rec_track4_b.oldorders
FROM         Staging.dbo.rec_track4_b CROSS JOIN
                      Staging.dbo.rec_track4

--------------- new case net of oldorders where date is now ---------------------
--declare @period varchar (4)
--declare	@x as smalldatetime
--select		@x = staging.dbo.fn_dateonly(dateadd(dd,0,getdate()))
--SELECT     period
--FROM         Tmp_Load.dbo.track_dte3
--WHERE     (date = @x)
--SELECT Period, 
--            rec_plan, 
--            orders, 
--            receipts, 
--            case 
--              when Period = @period 
--                then rec_plan - orders - receipts - oldorders 
--             else rec_plan - orders - receipts 
--            end as over_under
--FROM Staging.dbo.rec_track6
declare @period varchar(4)
declare @x as smalldatetime
select @x = staging.dbo.fn_dateonly(dateadd(dd,0,getdate()))
SELECT @period = period
FROM Tmp_Load.dbo.track_dte3
WHERE (date = @x)
truncate table staging.dbo.rec_track7
insert into staging.dbo.rec_track7
SELECT Period, 
rec_plan, 
orders, 
receipts, 
case 
when Period = @period 
then rec_plan - orders - receipts - oldorders 
when period like 'old'
then 0
else rec_plan - orders - receipts 
end as over_under
FROM Staging.dbo.rec_track6
 






















































GO
