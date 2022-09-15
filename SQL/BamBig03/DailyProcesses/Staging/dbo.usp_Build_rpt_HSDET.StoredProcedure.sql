USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_HSDET]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_rpt_HSDET]
as
--
truncate table reference.dbo.rpt_hsdet
--
insert into	reference.dbo.rpt_hsdet
SELECT obcono
      ,obcsno
      ,oborno
      ,obwhid
      ,staging.dbo.fn_IntToDate(obrqdt)
	  ,staging.dbo.fn_IntToDate(obivdt)
      ,obitno
      ,obitcl
      ,obitd1
      ,obqtor
      ,obqtsh
      ,oblspr
      ,obaslp
	  ,oblnam
      ,obdscp
      ,'0'
  FROM Staging.dbo.wrk_rpt_HSDET
--
GO
