USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_AA_Inv]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_AA_Inv]
as
truncate table dssdata.dbo.AA_Store_Inv
insert into dssdata.dbo.aa_Store_Inv
select  t2.store_number,
		t1.isbn,
		t1.sku_number,
		t2.On_Hand,
		t2.On_Order
from	dssdata.dbo.CARD t1,
		Reference.dbo.invbal t2
where	t2.sku_number = t1.sku_number
and		t1.Module in (select AA_Code from reference.dbo.AA_Inv_Codes)
and     (NOT (t2.Store_number IN (3515,3577,3108,3197,3253,3517,3176,3487,2575,3575,3387,3777,
3622,3313,3240,3134,3286,3658,2100,2101,2102,10,11,12,13,15,9999,99999,55,60,986,987,988,989,990,995,997,
998,50,52,54,4001,4002,4003,4004,4005,4006,4007,4008,4009,4010,4011,4012,4013,4014,4015,4017)))
order by t2.store_number,t1.sku_number
GO
