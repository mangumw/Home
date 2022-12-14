SELECT IAITNO AS ItemNumber,
       IAWHID AS WarehouseID,
       IAUNMS AS UnitofMeasure,
       IATRCC AS TransactionCentury,
       CASE IATRCC
           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IATRDT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IATRDT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS TransactionDate,
       TIME(to_date(DIGITS(CAST(IATIME AS DEC(6, 0))), 'HH24MISS')) AS Time,
       IASQ04 AS SequenceNumber,
       IATRCD AS TransactionCode,
       IATRQT AS TransactionQuantity,
       IACSEX AS CostorExtension,
       IACECD AS CostorExtensionCode,
       IAQOLT AS QuantityonHandLastTransaction,
       IAACLT AS AverageCostLastTransaction,
       IAITGL AS ItemGLCode,
       IACONO AS CompanyNumber,
       IAPOCC AS GLPostingCentury,
       CASE IAPOCC
           WHEN 19 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(IAPODT + 19000000), 'YYYYMMDD'), 'YYYYMMDD')
           WHEN 20 THEN varchar_format(TIMESTAMP_FORMAT(CHAR(LPAD(IAPODT, 6, 0)), 'YYMMDD'), 'YYMMDD')
       END AS GLPostingDate,
       IAIAC1 AS InternalGLAcctNo1,
       IAIAC2 AS InternalGLAcctNo2,
       IAIAC3 AS InternalGLAcctNo3,
       IAIAC4 AS InternalGLAcctNo4,
       IAIAC5 AS InternalGLAcctNo5,
       IAIAC6 AS InternalGLAcctNo6,
       IAIAC7 AS InternalGLAcctNo7,
       IAIAC8 AS InternalGLAcctNo8,
       IAIAC9 AS InternalGLAcctNo9,
       IADRC1 AS DebitorCreditCode1,
       IADRC2 AS DebitorCreditCode2,
       IADRC3 AS DebitorCreditCode3,
       IADRC4 AS DebitorCreditCode4,
       IADRC5 AS DebitorCreditCode5,
       IADRC6 AS DebitorCreditCode6,
       IADRC7 AS DebitorCreditCode7,
       IADRC8 AS DebitorCreditCode8,
       IADRC9 AS DebitorCreditCode9,
       IAGLA1 AS Amount1,
       IAGLA2 AS Amount2,
       IAGLA3 AS Amount3,
       IAGLA4 AS Amount4,
       IAGLA5 AS Amount5,
       IAGLA6 AS Amount6,
       IAGLA7 AS Amount7,
       IAGLA8 AS Amount8,
       IAGLA9 AS Amount9,
       IAJRNL AS JournalNumber,
       IARRNO AS RelativeRecordNumber,
       IAREC# AS RecordNumber,
       IAORUS AS OriginalUser,
       IAIAB2 AS IAHistoryAccountBucket2,
       IAUPIN AS UpdateInventoryCode
    FROM APLUS2FAW.IAHST
    WHERE IATRDT = (SELECT VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD') - 1 FROM SYSIBM.SYSDUMMY1)