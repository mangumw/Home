USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_CARD_WOS]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Build_CARD_WOS]
as
declare @year int
declare @week int
declare @Last_Saturday smalldatetime
declare @Curve Float
declare @projected int
declare @Running float
declare @Cumulative Float
declare @BAM_WOS int
declare @Whse_WOS int
declare @BAM_OnHand int
declare @Whse_OnHand int
declare @week1units int
declare @sku int
--
select @Last_Saturday = staging.dbo.fn_Last_Saturday(getdate())
--
select @year = Fiscal_Year from reference.dbo.calendar_dim where day_date = @Last_Saturday
select @Year = @Year - 1
select @week = Fiscal_Year_week from reference.dbo.calendar_dim where day_date = @Last_Saturday
--
declare cardcur cursor for select sku_number from dssdata.dbo.card 
open cardcur
--
fetch next from cardcur into @sku
while @@Fetch_status = 0
begin

select @Week1Units = week1units from dssdata.dbo.card where sku_number = @sku
select @Bam_OnHand = BAM_OnHand + InTransit from dssdata.dbo.card where sku_number = @sku
select @Whse_OnHand = Warehouse_Onhand from dssdata.dbo.card where sku_number = @sku
--
select @Bam_wos = 0
select @Whse_WOS = 0
select @Cumulative = 0
select @running = 0
--
declare cur cursor for select curve from reference.dbo.WOS_Curve
                       where Year = @Year and Week >= @Week order by Week
open cur
--
fetch next from cur into @curve
select @Projected = @Week1Units / @curve 
--
while @@Fetch_Status = 0
begin
select @running = @projected * @curve
select @cumulative = @cumulative + @running
if (@BAM_OnHand > @Cumulative) and @Running > 0
  Select @Bam_Wos = @Bam_Wos + 1
if (@Whse_OnHand > @Cumulative) and @Running > 0
  Select @Whse_Wos = @Whse_Wos + 1
fetch next from cur into @curve
end
close cur
deallocate cur
--
update dssdata.dbo.card set BAM_WOS = @BAM_WOS,AWBC_WOS=@Whse_WOS where sku_number = @sku

fetch next from cardcur into @sku
end
--
close cardcur
deallocate cardcur

GO
