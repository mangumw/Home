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
    WHERE EGCDTE = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)
