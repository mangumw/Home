SELECT CSSTOR AS StoreNumber,
       CSCEN AS TransactionCentury,
       CASE cscen
           WHEN 0 THEN DATE(TIMESTAMP_FORMAT(CHAR(CSDATE + 19000000), 'YYYYMMDD'))
           WHEN 1 THEN to_date(CHAR(LPAD(CSDATE, 6, 0)), 'YYMMDD')
       END AS TransactionDate,
       CSREG# AS RegisterNumber,
       CSROLL AS RollOverNumber,
       CSTRN# AS TransactionNumber,
       CSSEQ# AS SequenceNumber,
       CSDTYP AS TransactionType,
       CSDAMT AS AmountTendered,
       CSDOC# AS TenderDocumentNumber,
       CSDSTS AS Status,
       CSCSH# AS CashierNumber,
       CSTIL AS TillNumber,
       CSCRD# AS CreditCardNumber,
       CSCRDX AS ExpiryDate,
       CSCAUT AS AuthorizationCode,
       CSPSSQ AS POSSeqNumber
    FROM MM4R4LIB.CSHTND
--    WHERE CSDATE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)