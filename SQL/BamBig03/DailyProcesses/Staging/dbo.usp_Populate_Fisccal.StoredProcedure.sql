USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Fisccal]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Populate_Fisccal]
as
delete from bamitr05.miscsales.dbo.fisccal
where caldate > '01-31-2009'
insert into bamitr05.miscsales.dbo.fisccal
select day_date,
		fiscal_period,
		fiscal_year,
		fiscal_period_week,
		fiscal_year_week,
		day_of_week_number,
		fiscal_year_week
		
from reference.dbo.calendar_dim
where day_date > '01-31-2009'

GO
