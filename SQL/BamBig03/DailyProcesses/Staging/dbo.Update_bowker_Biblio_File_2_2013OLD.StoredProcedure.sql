USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[Update_bowker_Biblio_File_2_2013OLD]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_bowker_Biblio_File_2_2013OLD]
AS

--- STRIP OUT SPACES AND DASHES FROM UPLOAD FILE : -----

update tmp_load..Bowker_Biblio_TMP 
set UPC = (select replace(UPC,' ', ''))
update tmp_load..Bowker_Biblio_TMP 
set UPC = (select replace(UPC,'-', ''))
update tmp_load..Bowker_Biblio_TMP 
set ReturnableIndicator = (select replace(ReturnableIndicator,'|', ''))

----- FIND LIST PRICE ----
/*UPDATE TMP_LOAD..BOWKER_BIBLIO_TMP
SET [PublisherListPrice] =[AvailablefromCo1Price]
WHERE [PublisherListPrice] = 0.00*/

--- update media indicator ---

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
           ,[MultivolumeSetParentTitleLeadingArticles]
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
           ,[Pagination]
           ,[CurrentLanguageCode]
           ,[OriginalLanguageCode]
           ,[Weight]
           ,[Length]
           ,[Width]
           ,[Height]
           ,[IllustratedIndicator]
           ,[AgeMinimum]
           ,[AgeMaximum]
           ,[GradeMinimum]
           ,[GradeMaximum]
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
           ,[AvailablefromCo1RecordNumber]
           ,[AvailablefromCo1Currency]
           ,[AvailablefromCo1Price]
           ,[AvailablefromCo2RecordNumber]
           ,[AvailablefromCo2Currency]
           ,[AvailablefromCo2Price]
           ,[AvailablefromCo3RecordNumber]
           ,[AvailablefromCo3Currency]
           ,[AvailablefromCo3Price]
           ,[AvailablefromCo4RecordNumber]
           ,[AvailablefromCo4Currency]
           ,[AvailablefromCo4Price]
           ,[AvailablefromCo5RecordNumber]
           ,[AvailablefromCo5Currency]
           ,[AvailablefromCo5Price]
           ,[AvailablefromCo6RecordNumber]
           ,[AvailablefromCo6Currency]
           ,[AvailablefromCo6Price]
           ,[AvailablefromCo7RecordNumber]
           ,[AvailablefromCo7Currency]
           ,[AvailablefromCo7Price]
           ,[AvailablefromCo8RecordNumber]
           ,[AvailablefromCo8Currency]
           ,[AvailablefromCo8Price]
           ,[AvailablefromCo9RecordNumber]
           ,[AvailablefromCo9Currency]
           ,[Availablefrom9Price]
           ,[AvailablefromCo10RecordNumber]
           ,[AvailablefromCo10Currency]
           ,[AvailablefromCo10Price]
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
           ,[PublisherDiscountCode]
           ,[CartonQuantity]
           ,[WholesalerRecordNumber]
           ,[AgentRecordNumber]
           ,[BowkerFictonSubjectType]
           ,[BestsellerCitations]
           ,[MediaMentions]
           ,[CCCFlag]
           ,[Ebook]
           ,[DOI]
           ,[LCCN]
           ,[LCClassificationNumber]
           ,[StreetDate]
           ,[OpDate]
           ,[ShipDate]
           ,[LastReturnDate]
           ,[ReturnableIndicator]
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
      ,[MultivolumeSetParentTitleLeadingArticles]
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
      ,[Pagination]
      ,[CurrentLanguageCode]
      ,[OriginalLanguageCode]
      ,[Weight]
      ,[Length]
      ,[Width]
      ,[Height]
      ,[IllustratedIndicator]
      ,[AgeMinimum]
      ,[AgeMaximum]
      ,[GradeMinimum]
      ,[GradeMaximum]
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
      ,[AvailablefromCo1RecordNumber]
      ,[AvailablefromCo1Currency]
      ,[AvailablefromCo1Price]
      ,[AvailablefromCo2RecordNumber]
      ,[AvailablefromCo2Currency]
      ,[AvailablefromCo2Price]
      ,[AvailablefromCo3RecordNumber]
      ,[AvailablefromCo3Currency]
      ,[AvailablefromCo3Price]
      ,[AvailablefromCo4RecordNumber]
      ,[AvailablefromCo4Currency]
      ,[AvailablefromCo4Price]
      ,[AvailablefromCo5RecordNumber]
      ,[AvailablefromCo5Currency]
      ,[AvailablefromCo5Price]
      ,[AvailablefromCo6RecordNumber]
      ,[AvailablefromCo6Currency]
      ,[AvailablefromCo6Price]
      ,[AvailablefromCo7RecordNumber]
      ,[AvailablefromCo7Currency]
      ,[AvailablefromCo7Price]
      ,[AvailablefromCo8RecordNumber]
      ,[AvailablefromCo8Currency]
      ,[AvailablefromCo8Price]
      ,[AvailablefromCo9RecordNumber]
      ,[AvailablefromCo9Currency]
      ,[Availablefrom9Price]
      ,[AvailablefromCo10RecordNumber]
      ,[AvailablefromCo10Currency]
      ,[AvailablefromCo10Price]
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
      ,[PublisherDiscountCode]
      ,[CartonQuantity]
      ,[WholesalerRecordNumber]
      ,[AgentRecordNumber]
      ,[BowkerFictonSubjectType]
      ,[BestsellerCitations]
      ,[MediaMentions]
      ,[CCCFlag]
      ,[Ebook]
      ,[DOI]
      ,[LCCN]
      ,[LCClassificationNumber]
      ,[OnSaleDate]as Streetdate
      ,[OpDate]
      ,[ShipDate]      
      ,[LastReturnDate]
      ,[ReturnableIndicator]
      ,getdate()/*'2012-05-19 01:01:01.001'*/
       
  FROM [Tmp_Load].[dbo].[Bowker_Biblio_TMP]

--load bipmstupd ---
----- FIND LIST PRICE ----
UPDATE TMP_LOAD..BOWKER_BIBLIO_TMP
SET [PublisherListPrice] =[AvailablefromCo1Price],
    [PublisherListPricecurrency] =[AvailablefromCo1Currency] 
WHERE [PublisherListPrice] = 0.00

UPDATE TMP_LOAD..BOWKER_BIBLIO_TMP
SET [PublisherListPrice] =[PublisherNetPrice],
    [PublisherListPriceCurrency] =[PublisherNetPriceCurrency]
WHERE [PublisherListPrice] = 0.00 

INSERT INTO 


 [BKL400].[BKL400].[MM4R4LIB].[BIPMSTUPD]
           ([RECORD],
           [ISBN]
           ,[TITLE]
           ,[TITLEA]
           ,[CONT1]
           ,[CONT1R]
           ,[CONT2]
           ,[CONT2R]
           ,[CONT3]
           ,[CONT3R]
           ,[PUBIMP]
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
           ,[RETURN])
    


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
publishername as 'pubimp',
publicationdate as 'pubdte',
OnSaleDate as 'strdte',
bindingcode1 as 'bisbtp',
BISACMediaindicator1 as 'BISMTP',
publisherdiscountcode as 'discde',
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
ageminimum as minage,
agemaximum as maxage,
grademinimum as grademinimum,
grademaximum as grademaximum,
dewey as [ddcls#],
pagination as pages,
weight,
length,
width,
height,
publisherlistprice as 'pubprc',
opdate,
shipdate as 'shpdte',
status,
returnableindicator
from 
TMP_LOAD.dbo.Bowker_Biblio_TMP







GO
