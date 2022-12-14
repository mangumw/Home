USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Item_Master]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Item_Master]

as
truncate table reference.dbo.item_master
--
insert into reference.dbo.item_master
select	t1.ISBN,
		t1.sku_number,
		right('000000000' + cast(t1.sku_number as varchar(20)),9) as sku_text,
		case
		  when left(t1.ISBN,3) = '978'
			then t1.ISBN
		  when isnumeric(left(t1.isbn,1)) = 0
		    then NULL
		  else
			NULL --staging.dbo.fn_IsbnToEAN(t1.isbn) 
		end as EAN,
		t1.sku_type,
		t1.Description as Title,
		t1.Description,
		t1.Author,
		'N' as Returnable,
--		case
--		when t5.DispCD in (1,2,5) then 'Y'
--		else 'N'
--		end as Returnable,
		t1.Status,
		t1.Pub_Code,
		t4.PUBNAME,
		t1.Vendor_Number,
		t1.Vendors_Number,
		t1.Manuf_Number,
		NULL as Manufs_Number,
		NULL as MfgItemNo,
		t1.Repl_Code,
		t1.Module,
		t1.Dept,
		t1.SDept,
		t1.Class,
		t1.SClass,
		NULL As Category,
		t3.DeptName,
		t3.SubDeptName,
		t3.ClassName,
		t3.SubClassName,
		t6.Byrnum,
		t6.Byrnam,
		t1.Subject,
		t1.Coordinate_Group,
		t1.Manuf_List,
		t1.Home_Cost,
		t1.Vendor_Cost,
		t1.POS_Price,
		t1.Init_Home_Cost,
		NULL as Suspend_Code,
		NULL as Void_Flag,
		t5.DispCd as Disposition,
		NULL as ILevel,
		t5.Level_Ind,
		t7.Min_Qty,
		t7.Max_Qty,
		getdate(),
		t1.Condition
from	Reference.dbo.INVMST t1 left join 
	Reference.dbo.Category_Master t3 
		on t3.Dept = t1.Dept and t3.Subdept = t1.sdept and t3.Class = t1.class and t3.subclass = t1.sclass
	left join Reference.dbo.Publisher t4 
		on t4.PUBCODE = t1.Pub_Code
	left join Reference.dbo.Invmste t8
	    on t1.sku_number = t8.sku_number
	left join reference.dbo.itmst t5  
		on t5.ISBN = t8.ISBN
	left join reference.dbo.tblbyr t6
		on t6.byrnum = t1.Buyer_Number
	left join reference.dbo.itbal t7
		on t7.sku_number = t1.sku_number
		and t7.warehouseID = 1
GO
