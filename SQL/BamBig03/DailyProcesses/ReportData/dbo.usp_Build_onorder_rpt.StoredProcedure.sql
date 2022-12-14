USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_onorder_rpt]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_onorder_rpt]
as




--- on order  report ---
drop table reportdata..onorder_rpt
declare @calendar_year int 
declare @max_date datetime 


select @calendar_year = 
calendar_year from reference.dbo.calendar_dim
where day_date in( select max(day_date) from dssdata..weekly_sales)
 
 
select @max_date = max(day_date) 
 from reference..calendar_dim
 where calendar_year =@calendar_year 








select 
isbn, 
sku_number, 
sku_type,
title,
pubcode,
buyername,
dept_name,
sdept_name,
class_name, 
order_date,
due_date, 
retail, 
qty_ordered, 
isnull(qty_received,0) as qty_received,
extended
into 

reportdata..onorder_rpt

from 
reference..item_master as a 
inner join 
reference..pos as b 
on a.isbn =b.item_number
where '20'+cast(due_date as varchar(6)) <= LEFT(CONVERT(VARCHAR, @max_date, 112), 12) 




GO
