USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_update_route_guide]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[usp_update_route_guide]
As

truncate table reference..route_guide
insert into reference..route_guide
select * from [BKL400].[BKL400].[MM4R4LIB].[PORCTRK] 
GO
