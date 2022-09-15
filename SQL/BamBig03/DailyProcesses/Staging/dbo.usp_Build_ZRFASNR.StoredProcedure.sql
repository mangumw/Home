USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_ZRFASNR]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_ZRFASNR]
as
--
truncate table reference.dbo.ZRFASNR
--
insert into reference.dbo.ZRFASNR
select	ASTPID,
		ASLINK,
		ASSHID,
		staging.dbo.fn_PDateToDate(ASADTE),
		ASATIM,
		ASCART,
		ASTWGT,
		ASWGHT,
		staging.dbo.fn_PDateToDate(ASSDTE),
		ASCARR,
		ASMANF,
		ASPONO,
		staging.dbo.fn_PDateToDate(ASPODT),
		ASINVN,
		ASTYPE,
		ASBARC,
		ASISBN,
		ASNUMB,
		ASSQTY,
		ASICAR,
		ASRCVR,
		staging.dbo.fn_PDateToDate(ASRCDT),
		ASRQTY,
		ASRBOX,
		ASTRKN,
		ASSUOM,
		ASPRIC,
		ASPRCD,
		ASSTAT
from	staging.dbo.ZRFASNR
where	ASSDTE < 20990101
and ASADTE > 20000000
and ASSDTE > 20000000













GO
