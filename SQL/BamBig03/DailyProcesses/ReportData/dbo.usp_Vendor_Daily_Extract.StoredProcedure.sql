USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Vendor_Daily_Extract]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Vendor_Daily_Extract]
@pub_name varchar(50)
as
Select @Pub_Name as Pub_Group, 
t1.ISBN,
t1.Title,
t1.Author,
t1.Sku_Type,
t1.IDate,
t1.Retail,
0 as Day1Units,
0 as Day2Units,
t1.TYYTDUnits + t1.DCTYYTDUnits as YTD_Units,
t1.BAM_OnHand,
t1.Warehouse_OnHand,
t1.Qty_OnOrder
into #tmp_pub
from DssData.dbo.CARD t1 
where t1.Pub_Code in (select pub from REFERENCE.DBO.PUB_GROUP where PUB_GRP = @Pub_Name)  
and t1.sku_type not in ('Z','V') 
--
update #tmp_pub set Day1Units =	(select isnull(sum(item_quantity),0) from dssdata.dbo.detail_transaction_period
							where ISBN = #tmp_pub.ISBN
							and day_date = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate())))
--
update #tmp_pub set Day1Units = Day1Units + (select isnull(sum(qty_ship),0) from reference.dbo.dc_detail
							where PID = #tmp_pub.ISBN
							and staging.dbo.fn_dateonly(time_shipped) = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate())))

select * from #tmp_pub


GO
