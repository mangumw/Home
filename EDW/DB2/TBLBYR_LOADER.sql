SELECT BYRNUM AS BuyerNumber,
       BYRNAM AS BuyerName,
       BYRSCN AS StartDateCenturyCode,
       varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(BYRSDT, 6, 0)), 'YYMMDD'), 'YYMMDD') AS StartDate,
       BYREXT AS TelExtension,
       BYRDWI AS DWInit,
       BYRSBC AS SrBuyerCode,
       BYRSEM AS SrBuyerEmail,
       BYRASC AS AsstBuyerCode,
       BYRASM AS AsstBuyerEmail
    FROM MM4R4LIB.TBLBYR