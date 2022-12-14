USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Build_2NC_ISBN_CrossRef]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Build_2NC_ISBN_CrossRef]
As

delete from staging.dbo.CrossRef2NC

insert into staging.dbo.CrossRef2NC
select IUPC as Item, INUMBR as Sku_Number, IUPC as DW_Item
from BKL400.BKL400.MM4R4LIB.INVUPC where IUPCCD = 'I' 

insert into staging.dbo.CrossRef2NC
select staging.dbo.fn_Convert_Isbn_13(IUPC) as Item, INUMBR as Sku_Number , IUPC as DW_Item
from BKL400.BKL400.MM4R4LIB.INVUPC where IUPCCD = 'E' and INUMBR not in (select INUMBR from BKL400.BKL400.MM4R4LIB.INVUPC
where IUPCCD = 'I') 


--delete from tmp_load.dbo.temp_CrossRef2NC

--insert into tmp_load.dbo.temp_CrossRef2NC
--select Isbn, Isbn as DW_ISBN
--from reference.dbo.itmst where isbn not in (select isbn from reference.dbo.invmste) and isbn not in (select Item from
--staging.dbo.CrossRef2NC) and len(rtrim(Isbn)) = 13

--delete from tmp_load.dbo.temp_CrossRef2NC where left(ISBN,1) in ('A', 'B', 'C', 'D', 'E', 'F', 'G','H', 'I', 'J',
--'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z') 

--delete from tmp_load.dbo.temp_CrossRef2NC where ISBN like '%X%' and len(ISBN) = 13

--delete from tmp_load.dbo.temp_CrossRef2NC where ISBN like '%0787944386%'

--update tmp_load.dbo.temp_CrossRef2NC set ISBN = replace(ISBN, '-', '')

--delete from tmp_load.dbo.temp_CrossRef2NC where len(rtrim(ISBN)) = 10

--update tmp_load.dbo.temp_CrossRef2NC set ISBN = staging.dbo.fn_Convert_Isbn_13(rtrim(ISBN))

--insert into staging.dbo.CrossRef2NC
--select isbn, 0, DW_ISBN from tmp_load.dbo.temp_CrossRef2NC
GO
