SELECT EGSTOR AS StoreNumber,
       TO_DATE(CHAR(EGDATE), 'YYYYMMDD') AS TransactionDate,
       EGDATE AS TD_RAW,       
       EGREG# AS RegisterNumber,
       EGROLL AS RollOverNumber,
       EGTRN# AS TransactionNumber,
       EGSEQ# AS SequenceNumber,
       EGDTYP AS TransactionType,
       EGEXTA AS ExtendedAmount,
       EGGCNM AS GiftCardNumber,
       EGGCAC AS GCAuthCode,
       TO_DATE(CHAR(EGCDTE), 'YYYYMMDD') AS DateCreated,
       EGCDTE AS DC_RAW,       
       EGPRGM AS ProgramName
    FROM MM4R4LIB.CSHEGC
    WHERE EGCDTE > (SELECT VARCHAR_FORMAT(CHAR(LAST_DAY(CURRENT DATE) + 1 day - 3 years),'YYYYMMDD') AS FIRST_DAY FROM SYSIBM.SYSDUMMY1)
