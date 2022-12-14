USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Build_One_Day_Sale_Rpt]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[Build_One_Day_Sale_Rpt]
as

  drop table reportdata..one_day_sale_rpt
  
declare @ods_date smalldatetime
select @ods_date =  convert(varchar, getdate()-1, 110) ;



With POS (Total_Sales, Total_Discount, Total_Non_Member_Sales, Total_Member_Sales) as ( select  sum(extended_price) as Total_Sales
,sum(Extended_Discount) as Total_Discount
,Total_Non_Member_Sales = sum(case when customer_number = 0 then Extended_Price else NULL end)
,Total_Member_Sales = sum(case when customer_number > 0 then Extended_Price else NULL end) from dssdata.dbo.detail_transaction_history
where day_date = @ods_date and store_number <> 55 ), Mem_Trans (Total_Member_Trans) as ( Select  Total_Member_Trans = count(Transaction_Number) 
from dssdata.dbo.Header_Transaction where day_date =@ods_date and store_number <> 55 and  Customer_Number > 0 ), 
Non_Mem_Trans (Total_Non_Member_Trans) as ( Select  Total_Non_Member_Trans = count(Transaction_Number) 
from dssdata.dbo.Header_Transaction where day_date =@ods_date and store_number <> 55 and  Customer_Number = 0 ), 
Avg_Mem_Trans (Avg_Member_Trans) as ( Select Avg_Member_Trans = Avg(Transaction_Amount) 
from dssdata.dbo.Header_Transaction where day_date = @ods_date and store_number <> 55 and  
Customer_Number > 0 ), Avg_Non_Mem_Trans (Avg_Non_Member_Trans) as ( Select Avg_Non_Member_Trans = Avg(Transaction_Amount) 
from dssdata.dbo.Header_Transaction where day_date = @ods_date and store_number <> 55 and  Customer_Number = 0
)
select  POS.Total_Sales
  ,POS.Total_Discount
  ,POS.Total_Non_Member_Sales
  ,POS.Total_Member_Sales
  ,Mem_Trans.Total_Member_Trans
  ,Non_Mem_Trans.Total_Non_Member_Trans
  ,Avg_Mem_Trans.Avg_Member_Trans
  ,Avg_Non_Mem_Trans.Avg_Non_Member_Trans
into #one_day_sale_rpt
from POS,
  Mem_Trans,
  Non_Mem_Trans,
  Avg_Mem_Trans,
  Avg_Non_Mem_Trans



declare @ods_date_PY smalldatetime
select @ods_date_PY =  convert(varchar, getdate()-365, 110) ;



With POS (Total_Sales, Total_Discount, Total_Non_Member_Sales, Total_Member_Sales) as ( select  sum(extended_price) as Total_Sales
,sum(Extended_Discount) as Total_Discount
,Total_Non_Member_Sales = sum(case when customer_number = 0 then Extended_Price else NULL end)
,Total_Member_Sales = sum(case when customer_number > 0 then Extended_Price else NULL end) from dssdata.dbo.detail_transaction_history
where day_date = @ods_date_py and store_number <> 55 ), Mem_Trans (Total_Member_Trans) as ( Select  Total_Member_Trans = count(Transaction_Number) 
from dssdata.dbo.Header_Transaction where day_date =@ods_date_py and store_number <> 55 and  Customer_Number > 0 ), 
Non_Mem_Trans (Total_Non_Member_Trans) as ( Select  Total_Non_Member_Trans = count(Transaction_Number) 
from dssdata.dbo.Header_Transaction where day_date =@ods_date_py and store_number <> 55 and  Customer_Number = 0 ), 
Avg_Mem_Trans (Avg_Member_Trans) as ( Select Avg_Member_Trans = Avg(Transaction_Amount) 
from dssdata.dbo.Header_Transaction where day_date = @ods_date_py and store_number <> 55 and  
Customer_Number > 0 ), Avg_Non_Mem_Trans (Avg_Non_Member_Trans) as ( Select Avg_Non_Member_Trans = Avg(Transaction_Amount) 
from dssdata.dbo.Header_Transaction where day_date = @ods_date_py and store_number <> 55 and  Customer_Number = 0
)
select  POS.Total_Sales as PY_Total_Sales
  ,POS.Total_Discount as PY_Total_Discount
  ,POS.Total_Non_Member_Sales as PY_Total_Non_Member_Sales
  ,POS.Total_Member_Sales as PY_Total_Member_Sales
  ,Mem_Trans.Total_Member_Trans as PY_Total_Member_Trans
  ,Non_Mem_Trans.Total_Non_Member_Trans as PY_Total_Non_Member_Trans
  ,Avg_Mem_Trans.Avg_Member_Trans as PY_Avg_Member_Trans
  ,Avg_Non_Mem_Trans.Avg_Non_Member_Trans as PY_Avg_Non_Member_Trans
  into #one_day_sale_rpt_py
from POS,
  Mem_Trans,
  Non_Mem_Trans,
  Avg_Mem_Trans,
  Avg_Non_Mem_Trans
  
  
 
  select * 
   into reportdata..one_day_sale_rpt
  from #one_day_sale_rpt
  cross join #one_day_sale_rpt_py

  
  drop table #one_day_sale_rpt
  drop table #one_day_sale_rpt_py


select * 
from  reportdata..one_day_sale_rpt
GO
