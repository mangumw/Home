USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_warranty]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------
  get the system date and run the report for the prior day
---------------------------------------------------------- */
CREATE procedure [dbo].[usp_build_warranty] as 
/* drop all tables used in process drop table #tmp_detail*/
truncate table reportdata..warranty_hdr
truncate table reportdata..warranty_dtl
truncate table reportdata..warranty_export_file
create table #help(field1 varchar(132))

/*----------------------------------------------------
   create the detail records for EW bands and put into a temp table
----------------------------------------------------- */

select  
'D' as record_type
,convert(varchar,day_date,112) as contract_purchase_date,
cast('136566068' as varchar) as client_id,
a.store_number,
cast(a.sku_number as varchar) as warranty_sku,
rtrim(b.description) as warranty_description
,sum(case when a.item_quantity >0  then a.item_quantity else 0  end) as quantity_sold
,sum(case when a.item_quantity <0 then a.item_quantity  else 0 end ) as quantity_cancelled
,sum(a.item_quantity) as net_contract_sales
,unit_retail as warranty_retail_price 
,unit_cost as warranty_cost
,sum(a.item_quantity * unit_cost) as total_amount_due
into  #tmp_detail
from dssdata..detail_transaction_history 
as a 
inner join 
reference..invmst as b
on a.sku_number = b.sku_number
where b.dept ='76'
and b.sku_type IN ('EW','E1','E2','E3','E4','E5','E6','E7','E8')
and a.sku_number < 999999901
and 
(convert(varchar,a.day_date,112) > (convert(varchar,getdate()-1,112) )) 
--and (convert(varchar,a.day_date,112) > (convert(varchar,getdate()-129,112) )) 
--and (convert(varchar,a.day_date,112) < (convert(varchar,getdate()-93,112) ))
-- (convert(varchar,a.day_date,112) = 20130712)
group by 
a.day_date,
a.store_number,
a.sku_number,
b.description,
unit_retail,
unit_cost



/*----------------------------------------------------
              insert detail into warranty dtl file 
-----------------------------------------------------*/


insert into reportdata..warranty_dtl
select * from #tmp_detail

select * from reportdata..warranty_dtl
/*----------------------------------------------------
   create the detail records for non-EW bands and put into a temp table
----------------------------------------------------- */

select  
'D' as record_type
,convert(varchar,day_date,112) as contract_purchase_date
,cast('136566068' as varchar) as client_id
,a.store_number
,cast(a.sku_number as varchar) as warranty_sku
,rtrim(b.description) as warranty_description
,sum(case when a.item_quantity >0  then a.item_quantity else 0  end) as quantity_sold
,sum(case when a.item_quantity <0 then a.item_quantity  else 0 end ) as quantity_cancelled
,sum(a.item_quantity) as net_contract_sales
,unit_retail as warranty_retail_price 
,unit_cost as warranty_cost
,sum(a.item_quantity * unit_cost) as total_amount_due
into  #tmp_detail1
from dssdata..detail_transaction_history 
as a 
inner join 
reference..invmst as b
on a.sku_number = b.sku_number
where b.dept ='76'
and a.sku_number < 999999901
and b.sku_type IN ('EW','E1','E2','E3','E4','E5','E6','E7','E8')
and (convert(varchar,a.day_date,112) >(convert(varchar,getdate()-1,112) )) 
--and (convert(varchar,a.day_date,112) > (convert(varchar,getdate()-129,112) )) 
--and (convert(varchar,a.day_date,112) < (convert(varchar,getdate()-128,112) ))
--and (convert(varchar,a.day_date,112) = 20130712)


group by 
a.day_date,
a.store_number,
a.sku_number,
b.description,
unit_retail,
unit_cost


/*----------------------------------------------------
              insert detail into warranty dtl file 
-----------------------------------------------------*/

insert into reportdata..warranty_dtl
select * from #tmp_detail1

/*----------------------------------------------------
  create the header record and put into a temp table 
-----------------------------------------------------*/
select 'H' as record_type,
'136566068' as client_id,
'BAM_'+CONVERT(VARCHAR(8), getdate(), 112)+cast(datepart("hour",getdate())as varchar)+cast(datepart("minute",getdate()) as varchar)+
cast(datepart("second",getdate())as varchar)+'.txt' as sales_file_name,
count(*) as record_count,
CONVERT(VARCHAR(8), getdate(), 112)+cast(datepart("hour",getdate())as varchar)+cast(datepart("minute",getdate()) as varchar)+
cast(datepart("second",getdate())as varchar) as date_time_stamp,
convert(varchar,getdate()-1,112) as record_start_date,  --sb -1
convert(varchar,getdate()-1,112) as record_end_date,
'BAM_'+CONVERT(VARCHAR(8), getdate(), 112)+cast(datepart("hour",getdate())as varchar)+cast(datepart("minute",getdate()) as varchar)+
cast(datepart("second",getdate())as varchar) as transmission_id
into #tmp_header
from dssdata..detail_transaction_history 
as a 
inner join 
reference..invmst as b
on a.sku_number = b.sku_number
where b.dept ='76'
and a.sku_number < 999999901
and (convert(varchar,a.day_date,112) > (convert(varchar,getdate()-1,112) ))
--and (convert(varchar,a.day_date,112) = 20130712)



/*----------------------------------------------------
              insert detail into warranty dtl file 
-----------------------------------------------------*/

insert into reportdata..warranty_hdr
select * from #tmp_header

update reportdata..warranty_hdr
set record_count = (select count(*) from reportdata..warranty_dtl)


/*----------------------------------------------------
  insert warranty hdr file into table with one field
-----------------------------------------------------*/

insert into #help(field1)
select 
record_type  + '|' + 
client_id  + '|' + 
sales_file_name + '|' +
cast(record_count as varchar(10)) + '|' + 
date_time_stamp + '|' + 
convert(varchar,record_start_date,20) + '|' + 
convert (varchar,record_end_date,20) + '|' + 
transmission_id  
from reportdata.dbo.warranty_hdr

/*----------------------------------------------------
  insert warranty dtl file into table with one field
-----------------------------------------------------*/

insert into #help(field1)
select 
record_type  + '|' + 
contract_purchase_date  + '|' + 
client_id + '|' +
cast(store_number as varchar(10)) + '|' + 
cast(warranty_sku as varchar(10)) + '|' + 
warranty_description + '|' +
cast(quantity_sold as varchar(10)) + '|' + 
cast(quantity_cancelled as varchar(10)) + '|' + 
cast(net_contract_sales as varchar(10)) + '|' + 
cast(warranty_retail_price as varchar(10)) + '|' + 
cast(warranty_cost as varchar(10)) + '|' + 
cast(total_amount_due as varchar(10)) 
from reportdata.dbo.warranty_dtl

insert into reportdata..warranty_export_file
select * from #help

select 
sales_file_name as filename 
from reportdata.dbo.warranty_hdr

insert into reportdata..warranty_dtl_cumulative
select * from reportdata..warranty_dtl

drop table #tmp_detail1
drop table #tmp_detail
drop table #tmp_header
drop table #help 
select * from reportdata..warranty_export_file



GO
