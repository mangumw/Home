USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_populate_Category_Master]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE PROCEDURE [dbo].[usp_populate_Category_Master]
AS
declare @oldbyr char(3)
declare @dept decimal(3,0),
	@dptnam varchar(50),
	@DeptName varchar(50),
	@sdept decimal(3,0),
	@SubDeptName varchar(50),
	@class decimal(3,0),
	@ClassName varchar(50),
	@sclass decimal(3,0),
	@SubClassName varchar(50),
	@idbuyr char(3),
	@BuyerName varchar(50),
	@Sr_Buyer varchar(50),
	@Buyer_EMail varchar(50),
	@Sr_Buyer_EMail varchar(50)
--	
declare dept_cursor cursor for 
select 	dept,
	sdept,
	class,
	sclass,
	Dept_Name,
	buyer
from 	reference.dbo.invdpt
order by dept,sdept,class,sclass
--
truncate table reference.dbo.Category_Master
--
open dept_cursor
--
fetch next from dept_cursor
into	@dept,
	@sdept,
	@class,
	@sclass,
	@dptnam,
	@idbuyr
--
while @@fetch_status = 0
begin
--
	if (@sclass <> 0) select @SubClassName = @dptnam
	else
        if (@class <> 0) select @ClassName = @dptnam
	else
	if (@sdept <> 0) select @SubDeptName = @dptnam
	else
	select @DeptName = @dptnam
--
	if (@idbuyr = '')
	begin
          select @idbuyr = @oldbyr
	end
	select @oldbyr = @idbuyr
	select @BuyerName = Buyer, @Sr_Buyer = Sr_Buyer, 
	@Buyer_EMail = Buyer_EMail, @Sr_Buyer_EMail = SrBuyer_EMail 
    from reference.dbo.Buyer_srbuyer_XRef where Buyer_Number = @idbuyr
	--
	insert into reference.dbo.Category_Master values (	@dept,
					@sdept,
					@class,
					@sclass,
					@DeptName,
					@SubDeptName,
					@ClassName,
					@SubClassName,
					@Sr_Buyer,
					NULL,
					@idbuyr,
					@BuyerName,
					@Buyer_EMail,
					@Sr_Buyer_EMail )
--	
	fetch next from dept_cursor
	into	@dept,
		@sdept,
		@class,
		@sclass,
		@dptnam,
		@idbuyr
end
--
close dept_cursor
deallocate dept_cursor
--
update reference.dbo.category_master
set reference.dbo.category_master.sr_buyer_name = reference.dbo.buyer_xref.sr_buyer_Name
from reference.dbo.buyer_xref
where reference.dbo.buyer_xref.buyer_number = reference.dbo.category_master.buyernumber



GO
