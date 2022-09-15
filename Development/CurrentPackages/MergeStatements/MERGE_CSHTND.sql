ALTER PROCEDURE dbo.MERGE_CSHTND
AS
BEGIN
MERGE   EDW.dbo.CSHTND as target 
USING   EDW.stg.CSHTND as source
ON
    (
        target.StoreNumber                      = source.StoreNumber
        and target.TransactionDate              = source.TransactionDate
        and target.TransactionNumber            = source.TransactionNumber
        and target.SequenceNumber               = source.SequenceNumber
        and target.AmountTendered               = source.AmountTendered
        and target.CreditCardNumber             = source.CreditCardNumber
    )
  WHEN MATCHED THEN UPDATE
        SET target.StoreNumber                  = source.StoreNumber,
            target.TransactionCentury           = source.TransactionCentury, 
            target.TransactionDate              = source.TransactionDate,
            target.RegisterNumber               = source.RegisterNumber,
            target.RollOverNumber               = source.RollOverNumber,
            target.TransactionNumber            = source.TransactionNumber,
            target.SequenceNumber               = source.SequenceNumber,
            target.TransactionType              = source.TransactionType,
            target.AmountTendered               = source.AmountTendered,
            target.TenderDocumentNumber         = source.TenderDocumentNumber,
            target.[Status]                     = source.[Status],
            target.CashierNumber                = source.CashierNumber,
            target.TillNumber                   = source.TillNumber,
            target.CreditCardNumber             = source.CreditCardNumber,
            target.ExpiryDate                   = source.ExpiryDate,
            target.AuthorizationCode            = source.AuthorizationCode,
            target.POSSeqNumber                 = source.POSSeqNumber,
            target.Last_Modified                = source.Last_Modified
 WHEN NOT MATCHED BY TARGET THEN
        INSERT  
            (
                StoreNumber,
                TransactionCentury,
                TransactionDate,
                RegisterNumber,
                RollOverNumber,
                TransactionNumber,
                SequenceNumber,
                TransactionType,
                AmountTendered,
                TenderDocumentNumber,
                [Status],
                CashierNumber,
                TillNumber,
                CreditCardNumber,
                ExpiryDate,
                AuthorizationCode,
                POSSeqNumber,
                Last_Modified
            )   
        VALUES
            (
                source.StoreNumber,
                source.TransactionCentury,
                source.TransactionDate,
                source.RegisterNumber,
                source.RollOverNumber,
                source.TransactionNumber,
                source.SequenceNumber,
                source.TransactionType,
                source.AmountTendered,
                source.TenderDocumentNumber,
                source.[Status],
                source.CashierNumber,
                source.TillNumber,
                source.CreditCardNumber,
                source.ExpiryDate,
                source.AuthorizationCode,
                source.POSSeqNumber,
                source.Last_Modified
            )  
    ;                    
END;   