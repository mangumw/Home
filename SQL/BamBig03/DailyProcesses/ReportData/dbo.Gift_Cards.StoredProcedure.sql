USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[Gift_Cards]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Leslie Adams>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- changes for new BOWKER Format
-- =============================================
CREATE PROCEDURE [dbo].[Gift_Cards]
AS

--- Replace Balance Records -----
delete reportdata..GIFTCARD_BALANCES
from tmp_load..GIFTCARD_BALANCES_tmp as a 
inner join reportdata..GIFTCARD_BALANCES as b 
on a.[ACCT] = b.[ACCT]

INSERT INTO reportdata..GIFTCARD_BALANCES
SELECT * FROM tmp_load..GIFTCARD_BALANCES_tmp


delete TMP_LOAD..GIFTCARD_DETAIL_TMP
from REPORTDATA..GIFTCARD_BALANCES as a 
inner join TMP_LOAD..GIFTCARD_DETAIL_TMP as b 
on a.[ACCT] = b.[ACCT]


INSERT INTO TMP_LOAD.dbo.GIFTCARD_DETAIL_tmp_HOLD
SELECT * FROM 
TMP_LOAD.dbo.GIFTCARD_DETAIL_tmp









update TMP_LOAD..BOWKER_BIBLIO_TMP
set BISACMediaIndicator1 = (select media_indicator from dssdata..Media_Indicator_Xref b
    where bindingcode1 = b.binding_code
      and bindingcode1 <>''
      and BISACMediaIndicator1 = '')

update TMP_LOAD..BOWKER_BIBLIO_TMP
set BISACMediaIndicator2 = (select media_indicator from dssdata..Media_Indicator_Xref b
    where bindingcode2 = b.binding_code
      and bindingcode2 <>''
      and BISACMediaIndicator2 = '')

update TMP_LOAD..BOWKER_BIBLIO_TMP
set BISACMediaIndicator1 = '' where BISACMediaIndicator1 is null

update TMP_LOAD..BOWKER_BIBLIO_TMP
set BISACMediaIndicator2 = '' where BISACMediaIndicator2 is null

-----update pubdate to format of yyyymmdd ------------

/*update tmp_load.dbo.Bowker_Biblio_tmp
set publicationdate = publicationdate + '0101'
where len(publicationdate) = 4 


update tmp_load.dbo.Bowker_Biblio_tmp
set publicationdate = publicationdate + '01'
where len(publicationdate) = 6
*/

------------ put any pub changes into staging..bowker_biblio_pub_changes
--truncate table dssdata..bowker_biblio_pub_changes

insert into dssdata..bowker_biblio_pub_changes
    ([ItemRecordNumber] ,
	[PublisherRecordNumber_Old] ,
	[ImprintRecordNumber_Old] ,
    [PublisherRecordNumber_New] ,
	[ImprintRecordNumber_New] ,
	[Load_Date] )
select 
[ItemRecordNumber], 
'',
'',
[PublisherRecordNumber] ,
[ImprintRecordNumber],
convert(varchar,getdate(),112) from tmp_load..bowker_biblio_tmp

update dssdata..bowker_biblio_pub_changes
SET 
[PublisherRecordNumber_Old] = b.[PublisherRecordNumber],
[ImprintRecordNumber_Old] = b.[ImprintRecordNumber]
FROM dssdata..bowker_biblio_pub_changes A INNER JOIN dssdata..bowker_biblio B ON A.itemrecordnumber = B.itemrecordnumber
where a.Load_date = convert(varchar,getdate(),112)

delete from dssdata..bowker_biblio_pub_changes
where [PublisherRecordNumber_Old] = '' and 
[ImprintRecordNumber_Old] = ''

delete from dssdata..bowker_biblio_pub_changes
where 
[PublisherRecordNumber_Old] = [PublisherRecordNumber_New] and 
[ImprintRecordNumber_Old]  = [ImprintRecordNumber_New] 


--- delete new updated records ---
delete dssdata..bowker_biblio
from tmp_load..bowker_biblio_tmp as a 
inner join dssdata..bowker_biblio as b 
on a.[ItemRecordNumber] = b.[ItemRecordNumber]


--- append bibliographic_bowker_records with new records ---
INSERT INTO [dssdata].[dbo].[Bowker_Biblio]
           ([ItemRecordNumber]
           ,[ISBN10]
           ,[UPC]
           ,[EAN]
           ,[Status]
           ,[TypeofRecord]
           ,[BindingCode1]
           ,[BindingCode2]
           ,[BISACMediaIndicator1]
           ,[BISACMediaIndicator2]
           ,[Title]
           ,[TitleLeadingArticle]
           ,[VolumeNumber]
           ,[NumberofVolume]
           ,[BoundwithTitle]
           ,[MultivolumeSetParentTitle]
           ,[MultiVolumeSetParentTitleLeadingArticle]
           ,[EditionInformation]
           ,[EditionNumber]
           ,[CopyrightDate]
           ,[PublicationDate]
           ,[Contributor1]
           ,[Contributor1Function]
           ,[Contributor1CorporateFlag]
           ,[Contributor2]
           ,[Contributor2Function]
           ,[Contributor2CorporateFlag]
           ,[Contributor3]
           ,[Contributor3Function]
           ,[Corporate3CorporateFlag]
           ,[Contributor4]
           ,[Contributor4Function]
           ,[Contributor4CorporateFlag]
           ,[Contributor5]
           ,[Contributor5Function]
           ,[Contributor5CorporateFlag]
           ,[NumberOfPages]
           ,[CurrentLanguageCode]
           ,[OriginalLanguageCode]
           ,[Weight]
           ,[Length]
           ,[Width]
           ,[Height]
           ,[IllustratedIndicator]
           ,[LowerAge]
           ,[UpperAge]
           ,[LowerGrade]
           ,[UpperGrade]
           ,[Audience]
           ,[Dewey]
           ,[DeweyEdition]
           ,[SeriesTitle]
           ,[SeriesTitleLeading Article]
           ,[SeriesVolumeNumber]
           ,[SeriesISSN]
           ,[PublisherRecordNumber]
           ,[PublisherListPriceCurrency]
           ,[PublisherListPrice]
           ,[PublisherNetPriceCurrency]
           ,[PublisherNetPrice]
           ,[ImprintRecordNumber]
           ,[Distributor1RecordNumber]
           ,[Distributor1CurrencyCode]
           ,[Distributor1Price]
           ,[Distributor2RecordNumber]
           ,[Distributor2CurrencyCode]
           ,[Distributor2Price]
           ,[Distributor3RecordNumber]
           ,[Distributor3CurrencyCode]
           ,[Distributor3Price]
           ,[Distributor4RecordNumber]
           ,[Distributor4CurrencyCode]
           ,[Distributor4Price]
           ,[Distributor5RecordNumber]
           ,[Distributor5CurrencyCode]
           ,[Distributor5Price]
           ,[Distributor6RecordNumber]
           ,[Distributor6CurrencyCode]
           ,[Distributor6Price]
           ,[Distributor7RecordNumber]
           ,[Distributor7CurrencyCode]
           ,[Distributor7Price]
           ,[Distributor8RecordNumber]
           ,[Distributor8CurrencyCode]
           ,[Distributor8Price]
           ,[Distributor9RecordNumber]
           ,[Distributor9CurrencyCode]
           ,[Distributor9Price]
           ,[Distributor10RecordNumber]
           ,[Distributor10CurrencyCode]
           ,[Distributor10Price]
           ,[BowkerSubject1]
           ,[BowkerSubject2]
           ,[BowkerSubject3]
           ,[BowkerSubject4]
           ,[BowkerSubject5]
           ,[BowkerSubject6]
           ,[BowkerSubject7]
           ,[BowkerSubject8]
           ,[BowkerSubject9]
           ,[BowkerSubject10]
           ,[BISACSubjectCode1]
           ,[BISACSubjectCode2]
           ,[BISACSubjectCode3]
           ,[BISACSubjectCode4]
           ,[BISACSubjectCode5]
           ,[BISACSubjectCode6]
           ,[BISACSubjectCode7]
           ,[BISACSubjectCode8]
           ,[BISACSubjectCode9]
           ,[BISACSubjectCode10]
           ,[BICSubjectCode1]
           ,[BICSubjectCode2]
           ,[BICSubjectCode3]
           ,[BICSubjectCode4]
           ,[BICSubjectCode5]
           ,[BICSubjectCode6]
           ,[BICSubjectCode7]
           ,[BICSubjectCode8]
           ,[BICSubjectCode9]
           ,[BICSubjectCode10]
           ,[BowkerProductCode]
           ,[BowkerItemRecordNumber]
           ,[BarcodeIndicator]
           ,[ISBN13]
           ,[BowkerTitleRecordNumber]
           ,[BowkerMVSParentTitleRecordNumber]
           ,[MediaClass]
           ,[Contributor1RecordNumber]
           ,[Contributor2RecordNumber]
           ,[Contributor3RecordNumber]
           ,[Contributor4RecordNumber]
           ,[Contributor5RecordNumber]
           ,[LargePrintIndicator]
           ,[SeriesTitleRecordNumber]
           ,[PublisherName]
           ,[DiscountCode]
           ,[CartonQuantity]
           ,[WholesalerRecordNumber]
           ,[AgentRecordNumber]
           ,[BowkerFictonSubjectType]
           ,[BestsellerCitations]
           ,[MediaMentions]
           ,[CCCFlag]
           ,[EbookFormat]
           ,[DOI]
           ,[LCCN]
           ,[LCClassificationNumber]
           ,[OnSaleDate]
           ,[ShipDate]
           ,[OPDate]
           ,[LastReturnDate]
           ,[ReturnableIndicator]
           ,[PublisherProvidedBISACSubject1]
           ,[PublisherProvidedBISACSubject2]
           ,[PublisherProvidedBISACSubject3]
           ,[PublisherProvidedBICSubject1]
           ,[PublisherProvidedBICSubject2]
           ,[PublisherProvidedBICSubject3]
           ,[Load_Date])

SELECT [ItemRecordNumber]
           ,[ISBN10]
           ,[UPC]
           ,[EAN]
           ,[Status]
           ,[TypeofRecord]
           ,[BindingCode1]
           ,[BindingCode2]
           ,[BISACMediaIndicator1]
           ,[BISACMediaIndicator2]
           ,[Title]
           ,[TitleLeadingArticle]
           ,[VolumeNumber]
           ,[NumberofVolume]
           ,[BoundwithTitle]
           ,[MultivolumeSetParentTitle]
           ,[MultiVolumeSetParentTitleLeadingArticle]
           ,[EditionInformation]
           ,[EditionNumber]
           ,[CopyrightDate]
           ,[PublicationDate]
           ,[Contributor1]
           ,[Contributor1Function]
           ,[Contributor1CorporateFlag]
           ,[Contributor2]
           ,[Contributor2Function]
           ,[Contributor2CorporateFlag]
           ,[Contributor3]
           ,[Contributor3Function]
           ,[Corporate3CorporateFlag]
           ,[Contributor4]
           ,[Contributor4Function]
           ,[Contributor4CorporateFlag]
           ,[Contributor5]
           ,[Contributor5Function]
           ,[Contributor5CorporateFlag]
           ,[NumberOfPages]
           ,[CurrentLanguageCode]
           ,[OriginalLanguageCode]
           ,[Weight]
           ,[Length]
           ,[Width]
           ,[Height]
           ,[IllustratedIndicator]
           ,[LowerAge]
           ,[UpperAge]
           ,[LowerGrade]
           ,[UpperGrade]
           ,[Audience]
           ,[Dewey]
           ,[DeweyEdition]
           ,[SeriesTitle]
           ,[SeriesTitleLeading Article]
           ,[SeriesVolumeNumber]
           ,[SeriesISSN]
           ,[PublisherRecordNumber]
           ,[PublisherListPriceCurrency]
           ,[PublisherListPrice]
           ,[PublisherNetPriceCurrency]
           ,[PublisherNetPrice]
           ,[ImprintRecordNumber]
           ,[Distributor1RecordNumber]
           ,[Distributor1CurrencyCode]
           ,[Distributor1Price]
           ,[Distributor2RecordNumber]
           ,[Distributor2CurrencyCode]
           ,[Distributor2Price]
           ,[Distributor3RecordNumber]
           ,[Distributor3CurrencyCode]
           ,[Distributor3Price]
           ,[Distributor4RecordNumber]
           ,[Distributor4CurrencyCode]
           ,[Distributor4Price]
           ,[Distributor5RecordNumber]
           ,[Distributor5CurrencyCode]
           ,[Distributor5Price]
           ,[Distributor6RecordNumber]
           ,[Distributor6CurrencyCode]
           ,[Distributor6Price]
           ,[Distributor7RecordNumber]
           ,[Distributor7CurrencyCode]
           ,[Distributor7Price]
           ,[Distributor8RecordNumber]
           ,[Distributor8CurrencyCode]
           ,[Distributor8Price]
           ,[Distributor9RecordNumber]
           ,[Distributor9CurrencyCode]
           ,[Distributor9Price]
           ,[Distributor10RecordNumber]
           ,[Distributor10CurrencyCode]
           ,[Distributor10Price]
           ,[BowkerSubject1]
           ,[BowkerSubject2]
           ,[BowkerSubject3]
           ,[BowkerSubject4]
           ,[BowkerSubject5]
           ,[BowkerSubject6]
           ,[BowkerSubject7]
           ,[BowkerSubject8]
           ,[BowkerSubject9]
           ,[BowkerSubject10]
           ,[BISACSubjectCode1]
           ,[BISACSubjectCode2]
           ,[BISACSubjectCode3]
           ,[BISACSubjectCode4]
           ,[BISACSubjectCode5]
           ,[BISACSubjectCode6]
           ,[BISACSubjectCode7]
           ,[BISACSubjectCode8]
           ,[BISACSubjectCode9]
           ,[BISACSubjectCode10]
           ,[BICSubjectCode1]
           ,[BICSubjectCode2]
           ,[BICSubjectCode3]
           ,[BICSubjectCode4]
           ,[BICSubjectCode5]
           ,[BICSubjectCode6]
           ,[BICSubjectCode7]
           ,[BICSubjectCode8]
           ,[BICSubjectCode9]
           ,[BICSubjectCode10]
           ,[BowkerProductCode]
           ,[BowkerItemRecordNumber]
           ,[BarcodeIndicator]
           ,[ISBN13]
           ,[BowkerTitleRecordNumber]
           ,[BowkerMVSParentTitleRecordNumber]
           ,[MediaClass]
           ,[Contributor1RecordNumber]
           ,[Contributor2RecordNumber]
           ,[Contributor3RecordNumber]
           ,[Contributor4RecordNumber]
           ,[Contributor5RecordNumber]
           ,[LargePrintIndicator]
           ,[SeriesTitleRecordNumber]
           ,[PublisherName]
           ,[DiscountCode]
           ,[CartonQuantity]
           ,[WholesalerRecordNumber]
           ,[AgentRecordNumber]
           ,[BowkerFictonSubjectType]
           ,[BestsellerCitations]
           ,[MediaMentions]
           ,[CCCFlag]
           ,[EbookFormat]
           ,[DOI]
           ,[LCCN]
           ,[LCClassificationNumber]
           ,[OnSaleDate]
           ,[ShipDate]
           ,[OPDate]
           ,[LastReturnDate]
           ,[ReturnableIndicator]
           ,[PublisherProvidedBISACSubject1]
           ,[PublisherProvidedBISACSubject2]
           ,[PublisherProvidedBISACSubject3]
           ,[PublisherProvidedBICSubject1]
           ,[PublisherProvidedBICSubject2]
           ,[PublisherProvidedBICSubject3]
		   ,convert(varchar,getdate(),112)
 --        ,getdate()/*'2012-05-19 01:01:01.001'*/
       
  FROM [Tmp_Load].[dbo].[Bowker_Biblio_TMP]

--load bipmstupd ---
----- FIND LIST PRICE ----
UPDATE TMP_LOAD..BOWKER_BIBLIO_TMP
SET [PublisherListPrice] =[Distributor1Price],
    [PublisherListPricecurrency] =[Distributor1CurrencyCode] 
WHERE [PublisherListPrice] = 0.00

UPDATE TMP_LOAD..BOWKER_BIBLIO_TMP
SET [PublisherListPrice] =[PublisherNetPrice],
    [PublisherListPriceCurrency] =[PublisherNetPriceCurrency]
WHERE [PublisherListPrice] = 0.00 

-----update pubdate to format of yyyymmdd ------------

update tmp_load.dbo.Bowker_Biblio_tmp
set publicationdate = publicationdate + '0101'
where len(publicationdate) = 4 


update tmp_load.dbo.Bowker_Biblio_tmp
set publicationdate = publicationdate + '01'
where len(publicationdate) = 6

update TMP_LOAD..BOWKER_BIBLIO_TMP
set contributor5 = ''

update TMP_LOAD..BOWKER_BIBLIO_TMP
set contributor5 = (select companyname from dssdata..Bowker_Publisher b
    where ImprintRecordNumber = b.CompanyRecordNumber and ImprintRecordNumber <> '')

INSERT INTO 

 [BKL400].[BKL400].[MM4R4LIB].[BIPMSTUPD]
           ([RECORD]
           ,[ISBN]
           ,[TITLE]
           ,[TITLEA]
           ,[CONT1]
           ,[CONT1R]
           ,[CONT2]
           ,[CONT2R]
           ,[CONT3]
           ,[CONT3R]
           ,[PUBIMP]
		   ,[PUBNME]	
           ,[PUBDTE]
           ,[STRDTE]
           ,[BISBTP]
           ,[BISMTP]
           ,[DISCDE]
           ,[RTNFLG]
           ,[FRTNDT]
           ,[ISBN13]
           ,[UPC]
           ,[EAN]
           ,[BSUBJ1]
           ,[BSBDS1]
           ,[BSUBJ2]
           ,[BSBDS2]
           ,[BSUBJ3]
           ,[BSBDS3]
           ,[MINAGE]
           ,[MAXAGE]
           ,[MINGRD]
           ,[MAXGRD]
           ,[DDCLS#]
           ,[PAGES]
           ,[WEIGHT]
           ,[LENGTH]
           ,[WIDTH]
           ,[HEIGHT]
           ,[PUBPRC]
           ,[OPDATE]
           ,[SHPDTE]
           ,[status]
           ,[RETURN]
		   ,[PUBRCD]
		   ,[IMPRCD])
   
select 
itemrecordnumber,
isbn10 as 'isbn',
title,
cast(titleleadingarticle as varchar(12)) as titlea, 
contributor1 as 'cont1',
contributor1function as 'cont1r',
contributor2 as 'cont2',
contributor2function as 'cont2r',
contributor3 as 'cont3',
contributor3function as 'cont3r',
ISNULL(CAST(contributor5 as varchar(20)),'') as 'pubimp',
ISNULL(CAST(publishername as varchar(20)),'') as 'pubnme',
publicationdate as 'pubdte',
OnSaleDate as 'strdte',
bindingcode1 as 'bisbtp',
BISACMediaindicator1 as 'BISMTP',
discountcode as 'discde',
returnableindicator as 'rtnflg',
lastreturndate as 'frtndt',
isbn13,
upc, 
ean,
bisacsubjectcode1 as 'bsubj1',
bowkersubject1 as 'bsbds1',
bisacsubjectcode2 as 'bsubj2',
bowkersubject2 as 'bsbds2',
bisacsubjectcode1 as 'bsubj3',
bowkersubject1 as 'bsbds3',
lowerage as minage,
upperage as maxage,
lowergrade as grademinimum,
uppergrade as grademaximum,
dewey as [ddcls#],
numberofpages as pages,
weight,
length,
width,
height,
publisherlistprice as 'pubprc',
opdate,
shipdate as 'shpdte',
status,
returnableindicator,
ISNULL(CAST(publisherrecordnumber AS int),'') as 'pubrcd',
ISNULL(CAST(imprintrecordnumber AS INT),'') as 'imprcd'
from 
TMP_LOAD.dbo.Bowker_Biblio_TMP


--select top 1 * from [BKL400].[BKL400].[MM4D4LIB].[BIPMSTUPD]






GO
