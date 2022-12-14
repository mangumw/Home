USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Mass_500_Export]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Mass_500_Export]
as
declare @mcustnum varchar(12)
declare @mcompany varchar(40)
declare @mcreatedate varchar(10)
declare @address1 varchar(40)
declare @address2 varchar(40)
declare @address3 varchar(40)
declare @city varchar(20)
declare @country varchar(3)
declare @zip varchar(9)
declare @state varchar(3)
declare @EMail varchar(40)
declare @Phone varchar(17)
--
declare @CStr varchar(1000)
declare @RStr varchar(1000)
declare @OStr varchar(1000)
-- 
-- Clear out output table
--
Truncate table ReportData.dbo.MAss_500_Export
--
-- declare cursor for gclu row
--
declare cur cursor for 
  select	mcustnumint,
			mcompany,
			mcreatedate,
			aaddress1,
			aaddress2,
			aaddress3,
			acity,
			acountry,
			azip,
			astate,
			email,
			aphone
from		dssdata.dbo.GCLU
where		allowchrg = 'Y'
and			PClientType in ('MAC','INS')

--
Open cur
--
fetch next from cur into
			@mcustnum,
			@mcompany,
			@mcreatedate,
			@address1,
			@address2,
			@address3,
			@city,
			@country,
			@zip,
			@state,
			@email,
			@phone
--
-- Start Loop
--
while @@fetch_status = 0
begin
--
-- Fix MCreateDate
--
select @mcreatedate = substring(@mcreatedate,6,2) + '/' + right(rtrim(@mcreatedate),2) + '/' + left(@mcreatedate,4)
--
-- Construct C Type Record
--
select @CStr = 'C|||||BAM||||' + @mcustnum + '|BAM|' + @mcompany + '||' + @mcreatedate + '|||0|0|0|0|0||1|||||||||||||1|'
--
-- Construct R Type Record
--
select @RStr = 'R|1|1|1||' + @mcustnum + '|' + @mcustnum + '||||||0|||||' + @address1 + '|' + @address2 + '|' + @address3 + '|||' + @mcompany + '|' + @city + '|' + @country + '|' + @zip + '|' + @state + '|||||||||||1||'
--
-- Construct O Type Record
--
select @OStr = 'O|' + @mcustnum + '|' + @email + '|||' + @mcompany + '|' + @phone + '|1||'
--
-- Insert into output table
--
if @CStr IS NOT NULL  
begin
	insert into reportdata.dbo.Mass_500_Export values (@CStr)
	insert into reportdata.dbo.Mass_500_Export values (@RStr)
	insert into reportdata.dbo.Mass_500_Export values (@OStr)
end

--
-- Get Next Row
--
fetch next from cur into
			@mcustnum,
			@mcompany,
			@mcreatedate,
			@address1,
			@address2,
			@address3,
			@city,
			@country,
			@zip,
			@state,
			@email,
			@phone
--
-- End Loop
--
end
--
-- End Process
--
close cur
deallocate cur
--
GO
