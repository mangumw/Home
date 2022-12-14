USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_key_5_replen]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_key_5_replen]


as 
drop table key_repen_5

select vin,dept,
pub_code,isbn,
title,
idate,
sku_type,
class_name,
retail,
bam_onhand,store_min,
case when bam_onhand<0 then 0 else bam_onhand end as bam_oh_net, 
store_min as display_min_rollup,
qty_onbackorder,warehouse_onhand,
returncenter_onhand,qty_onorder,
week1units, week2units,
week3units,week13units, 
case when week1units>1 then 1 else 0 end as testwk1,
case when week2units>1 then 1 else 0 end as test2wk1,
case when week3units >1 then 1 else 0 end as test3wk1
into
#tmp_key_5_replen
from dssdata..card
where sku_type 
in ('i','n','t')
and pub_code
in ('MPB' , 'RHV','BNP','PBI','BSL','DAL','MP1','SRE')
and dept ='5'
and vin ='621'


--- step 1 ---

select 
vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
display_min_rollup,
case when (display_min_rollup*1.2)-bam_oh_net <1then 0 else  (display_min_rollup*1.2)-bam_oh_net end as bam_qty_to_disp_min_20,
case when sum(testwk1+test2wk1+test3wk1)>0 then (sum(week1units+week2units+week3units)/sum(testwk1+test2wk1+test3wk1))*3 else 0 end as min,
case when sum(testwk1+test2wk1+test3wk1)>0 then ((sum(week1units+week2units+week3units)/sum(testwk1+test2wk1+test3wk1))*3)*1.667 else 0 end as max,

qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
qty_onorder,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1
into #tmp_key_5_replen_a
from  #tmp_key_5_replen
--where isbn like '%785818960%'  

group by  
vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
display_min_rollup,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
qty_onorder,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1
 
 
--- step 2 --- 
select vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
bam_qty_to_disp_min_20,
display_min_rollup,
min,
max,
bam_qty_to_disp_min_20 +max as ttl_need,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
warehouse_onhand -returncenter_onhand as AV,
case when warehouse_onhand -returncenter_onhand <0 then 0 else warehouse_onhand -returncenter_onhand end as whse_oh_net,
qty_onorder,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1
into #tmp_key_5_replen_b
from 
#tmp_key_5_replen_a



---step 3 --- 


select vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
bam_qty_to_disp_min_20,
display_min_rollup,
min,
max,
ttl_need,
case when (ttl_need-whse_oh_net-qty_onorder) <0 then 0 else  (ttl_need-whse_oh_net-qty_onorder) end as new_suggested_order,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
AV,
whse_oh_net,
qty_onorder,
case when sum(testwk1+test2wk1+test3wk1)>0 then 
round((whse_oh_net+qty_onorder)/((week1units +week2units+week3units)/
(testwk1 +test2wk1 +test3wk1 )),0) else 0 end as wos_whse_oo,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1
into #tmp_key_5_replen_c
from 
#tmp_key_5_replen_b

group by  
vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
bam_qty_to_disp_min_20,
display_min_rollup,
min,
max,
ttl_need,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
AV,
whse_oh_net,
qty_onorder,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1


--- step 4 --- 
select vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
bam_qty_to_disp_min_20,
display_min_rollup,
min,
max,
ttl_need,
 new_suggested_order,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
AV,
whse_oh_net,
qty_onorder,
 wos_whse_oo,
case when (testwk1+test2wk1+test3wk1)>0 then
round((whse_oh_net+qty_onorder+new_suggested_order)/((week1units +week2units+week3units)/
(testwk1 +test2wk1 +test3wk1 )),0) else 0 end as wos_whse_oo_suggested,
case when (testwk1+test2wk1+test3wk1)>0 then
round((whse_oh_net+qty_onorder+new_suggested_order+bam_oh_net)/((week1units +week2units+week3units)/
(testwk1 +test2wk1 +test3wk1 )),0) else 0 end as wos_whse_oo_suggested_store,

week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1

into reportdata..key_repen_5
from #tmp_key_5_replen_c

--where isbn = '0766615251'


group by  
vin, 
dept, 
pub_code, 
isbn, 
title, 
idate, 
sku_type, 
class_name, 
retail, 
bam_onhand,
store_min,
bam_oh_net, 
bam_qty_to_disp_min_20,
display_min_rollup,
min,
max,
ttl_need,
qty_onbackorder,
warehouse_onhand,
returncenter_onhand,
AV,
whse_oh_net,
qty_onorder,
week1units, 
week2units, 
week3units, 
week13units,
testwk1,
test2wk1,
test3wk1,
new_suggested_order,
wos_whse_oo


order by isbn


drop table #tmp_key_5_replen
drop table #tmp_key_5_replen_a
drop table #tmp_key_5_replen_b
drop table #tmp_key_5_replen_c
GO
