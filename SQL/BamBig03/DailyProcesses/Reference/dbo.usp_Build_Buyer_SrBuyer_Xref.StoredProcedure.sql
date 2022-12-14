USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Buyer_SrBuyer_Xref]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Buyer_SrBuyer_Xref]
as

truncate table Reference.dbo.Buyer_SrBuyer_XRef

insert into Reference.dbo.Buyer_SrBuyer_XRef
select t1.BYRNUM, t1.BYRNAM, t2.BYRNAM,  t1.BYRSEM,t2.BYRSEM
from reference.dbo.tblbyr t1
left join reference.dbo.tblbyr t2 on t1.BYRDSBC = t2.BYRNUM 
where t1.BYRNUM <> 'RPL' and t1.BYRNUM <> 'ALL'

GO
