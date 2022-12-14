USE [SCC]
GO
/****** Object:  StoredProcedure [dbo].[usp_MigrateStores]    Script Date: 8/22/2022 1:57:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 09/01/2021
-- Description:	Stores migration from as400
-- =============================================
CREATE PROCEDURE [dbo].[usp_MigrateStores] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
truncate table tblStagingStores;

Insert into tblStagingStores (
StoreNumber,StoreName,AddressLine1,AddressLine2,AddressLine3,City,State,County,
Country,Zip,Phone,Fax,StoreShortName,RegionID,StoreManager,OpenDate,DateClosed,
SquareFoot,OnInterface,OpenedSunday,StoreOrOffice,WharehouseID,DistrictID
)

Select StoreNumber,StoreName,AddressLine1,AddressLine2,AddressLine3,City,State,County,
Country,Zip,Phone,Fax,StoreShortName,RegionID,StoreManager,OpenDate,DateClosed,
SquareFoot,OnInterface,OpenedSunday,StoreOrOffice,WharehouseID,DistrictID from openquery (bkl400, 'Select 
STRNUM AS StoreNumber,
STRNAM as StoreName,
STADD1 as AddressLine1,
STADD2 as AddressLine2,
STADD3 as AddressLine3,
STCITY as City,
STPVST as State,
STCNTY as County,
STCTRY as Country,
STZIP as Zip,
STPHON as Phone,
STFAXN as Fax,
STSHRT as StoreShortName,
REGNUM as RegionID,
STMNGR as StoreManager,
STSDAT as OpenDate,
STCLDT as DateClosed,
STRETL as SquareFoot,
STPOLL as OnInterface,
STSNDY as OpenedSunday,
STRHDO as StoreOrOffice,
STRWHS as WharehouseID,
STRDST as DistrictID
 from MM4R4LIB.TBLSTR')

update tblStagingStores
set Phone = replace(replace(replace(replace(replace(replace(replace(replace(Phone, '/', ''), ' ', ''), '-',''), '(', ''), ')', ''), '_', ''), 'USA', ''), 'TBD', '')

update tblStagingStores
set Fax = replace(replace(replace(replace(replace(replace(replace(replace(Phone, '/', ''), ' ', ''), '-',''), '(', ''), ')', ''), '_', ''), 'USA', ''), 'TBD', '')

create table #tmpemail(
StoreNumber varchar(5),
CompanyCode varchar (150)
)

insert into
#tmpemail
Select CCISTORE as StoreNumber, CCSTRA01 as CompanyCode from openquery(bkl400, 'Select CCISTORE, CCSTRA01 from MM4R4LIB.CYCTBATCH group by CCISTORE, CCSTRA01')

update #tmpemail
set CompanyCode = 
case 
when CompanyCode = 'BAM' then cast('MGR'+StoreNumber+'@booksamillion.com' as varchar (150))
when CompanyCode = 'BKLD' then cast('MGR'+StoreNumber+'@booksamillion.com' as varchar (150))
when CompanyCode = '2NC' then cast('MGR'+StoreNumber+'@2ndandcharles.com' as varchar (150))
end
from #tmpemail 

update st
set email = CompanyCode
from #tmpemail t inner join
tblStores st on t.storenumber = st.StoreNumber


 Insert into tblStores (
 StoreNumber,StoreName,AddressLine1,AddressLine2,AddressLine3,City,State,County,
Country,Zip,Phone,Fax,StoreShortName,RegionID,StoreManager,--OpenDate,DateClosed,
SquareFoot,OnInterface,OpenedSunday,StoreOrOffice,WharehouseID,DistrictID
)

Select st.StoreNumber,st.StoreName,st.AddressLine1,st.AddressLine2,st.AddressLine3,st.City,st.State,st.County,
st.Country,st.Zip,convert(bigint, st.Phone) as Phone,convert(bigint,st.fax) as Fax,st.StoreShortName,st.RegionID,st.StoreManager,--cast(st.OpenDate as Date) as OpenDate,cast(st.DateClosed as Date) as DateClosed,
st.SquareFoot,st.OnInterface,st.OpenedSunday,st.StoreOrOffice,st.WharehouseID,st.DistrictID
from tblStagingStores st left join
tblStores s on st.StoreNumber = s.StoreNumber
where s.StoreNumber is null



/****************************************join into batches so only active stores get email updates 02082022*****************************************/
--insert into tblEmails
--Select s.Storenumber, s.Email 
--from tblStores s inner join
--tblBatches b on s.storenumber = b.storenumber
--where email is not null and b.batchnumber is not null

--drop table #tmpemail
END

GO
