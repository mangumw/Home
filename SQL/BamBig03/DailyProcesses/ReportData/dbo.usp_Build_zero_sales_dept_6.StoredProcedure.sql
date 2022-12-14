USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_zero_sales_dept_6]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--
CREATE Procedure [dbo].[usp_Build_zero_sales_dept_6]
as 



declare @seldate smalldatetime
declare @enddate as smalldatetime
select @enddate = staging.dbo.fn_Last_Saturday(getdate())
select @seldate = dateadd(dd,-6,@enddate)

drop table  tmp_load..zero_sales_dept_6
--
select	Top 150
		@enddate as day_date,
      
t1.Store_Number,
		t1.isbn,
        t1.dept,
		t2.title,
		t2.author,
		t2.dept_name,
		t2.sdept_Name,
		sum(t1.Extended_Price) as Item_Sales,
		sum(t1.Item_Quantity) as Item_Qty
into #tmp_top_150_dept_6
from	Dssdata.dbo.detail_transaction_history t1,
		reference.dbo.item_master t2
where	t1.dept = '6'
and		t2.sku_number = t1.sku_number
and		t1.day_date >= @seldate and day_date <= @enddate
group by t1.store_number,t1.dept,t1.isbn,t2.title,t2.author,t2.dept_name,t2.sdept_name
order by t1.store_number,sum(t1.extended_price) desc








-- organization  -- 
select b.region_number,
b.district_name,
b.district_short_name,
a.district_number,
a.store_number,
a.store_name
into #tmp_organization 
from reference..store_dim as a 
inner join reference..district_dim as b 
on a.district_number =b.district_number
order by region_number,district_number,store_number



SELECT     a.Dept, a.Sku_Number, a.Description, b.Store_Number, 
           a.isbn,
                      c.Wk1_SLSU + c.Wk2_SLSU + c.Wk3_SLSU + c.Wk4_SLSU + c.Wk5_SLSU + c.Wk6_SLSU + c.Wk7_SLSU + c.Wk8_SLSU AS '8 wk sls', 
                      a.Sku_Type,d.district_name,d.district_number,d.store_name,d.region_number
into 

 tmp_load..zero_sales_dept_6

FROM         reference..INVMST AS a INNER JOIN
                      
 reference..Item_Display_Min AS b ON a.Sku_Number = b.Sku_Number INNER JOIN
                      reference..INVBAL AS c ON b.Sku_Number = c.sku_number AND b.Store_Number = c.Store_Number
inner join #tmp_organization  as d
on c.store_number =d.store_number
WHERE     (a.Sku_Type IN ('t', 'n', 'w')) AND (b.Display_Min > 0) AND 
                      (c.IBWKCR + c.Wk1_SLSU + c.Wk2_SLSU + c.Wk3_SLSU + c.Wk4_SLSU + c.Wk5_SLSU + c.Wk6_SLSU + c.Wk7_SLSU + c.Wk8_SLSU < 1) AND 
                      (a.Dept = 6)



select 
a.sku_number,
a.[8 wk sls],
a.sku_type,
a.district_name,
a.district_number,
a.store_name,
a.region_number,
b.*
into  
 reportdata..zero_sales_dept_6_data
from  tmp_load..zero_sales_dept_6 as a
inner join #tmp_top_150_dept_6 as b
on a.isbn =b.isbn



GO
