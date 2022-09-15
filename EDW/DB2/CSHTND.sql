select 
CSSTOR as StoreNumber,
CSCEN as TransactionCentury,
case cscen 
when 0 then date(timestamp_format(char(CSDATE+19000000), 'YYYYMMDD')) 
when 1 then to_date(char(LPAD(CSDATE,6,0)),'YYMMDD') end as TransactionDate,
CSREG# as RegisterNumber,
CSROLL as RollOverNumber,
CSTRN# as TransactionNumber,
CSSEQ# as SequenceNumber,
CSDTYP as TransactionType,
CSDAMT as AmountTendered,
CSDOC# as TenderDocumentNumber,
CSDSTS as Status,
CSCSH# as CashierNumber,
CSTIL as TillNumber,
CSCRD# as CreditCardNumber,
CSCRDX as ExpiryDate,
CSCAUT as AuthorizationCode,
CSPSSQ as POSSeqNumber
from MM4R4LIB.CSHTND
WHERE CSDATE >= VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD') - 1
--WHERE (CSDATE > varchar_format(current timestamp - 1 DAYS, 'YYYY-MM-DD')) AND (CSDATE < varchar_format(current timestamp, 'YYYY-MM-DD'));
--WHERE CSDATE >= CURRENT TIMESTAMP - 1 DAY