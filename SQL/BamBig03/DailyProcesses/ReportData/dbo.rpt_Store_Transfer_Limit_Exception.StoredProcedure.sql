USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Store_Transfer_Limit_Exception]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Store_Transfer_Limit_Exception]
as
--
declare @Qty_Limit int
declare @Retail_Limit money
--
select @Qty_Limit = Avg_Quantity,@Retail_Limit = Avg_Retail from reference.dbo.transfer_limits
--
truncate table Staging.dbo.Transfer_Limit_Report
insert into	Staging.dbo.Transfer_Limit_Report
select	t2.Init_Date,
		t1.Transfer_Batch,
		t2.From_Store,
		t2.To_Store,
		sum(t1.Qty_Requested) as Qty_Requested,
		sum(t1.Retail_In) as Retail
from	reference.dbo.TRFDTL t1,
		reference.dbo.TRFHDR t2
where	t2.init_date >= staging.dbo.fn_Last_Saturday(getdate())
and		t2.transfer_batch = t1.transfer_batch
group by t2.init_date,t1.transfer_batch,t2.from_store,t2.to_store
--
select	Init_Date,
		Transfer_Batch,
		From_Store,
		To_Store,
		Qty_Requested,
		Retail
from	Staging.dbo.Transfer_Limit_Report
where	Qty_Requested > @Qty_Limit
or		Retail > @Retail_Limit

		
GO
