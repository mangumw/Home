ALTER PROCEDURE dbo.MERGE_CSHSUM
AS
BEGIN
MERGE EDW.dbo.CSHSUM AS target
USING EDW.stg.CSHSUM AS source
ON  
    (
        target.StoreNumber              = source.StoreNumber
        AND target.TransactionCentury   = source.TransactionCentury
        AND target.TransactionDate      = source.TransactionDate
		AND target.RegisterNumber		= source.RegisterNumber
        AND target.RollOverNumber       = source.RollOverNumber
        AND target.TransactionNumber    = source.TransactionNumber
        AND target.TransactionTime      = source.TransactionTime
		AND target.TransactionType		= source.TransactionType
    )
WHEN MATCHED 
    AND target.TransactionDate          != source.TransactionDate
    OR  target.RegisterNumber           != source.RegisterNumber
    OR  target.TransactionTime          != source.TransactionTime
    OR  target.TransactionType          != source.TransactionType
    OR  target.TransactionAmount        != source.TransactionAmount
    OR  target.TenderAmount             != source.TenderAmount
    OR  target.CashierNumber            != source.CashierNumber
    OR  target.TillNumber               != source.TillNumber
    OR  target.SalespersonNo            != source.SalespersonNo
    OR  target.ProcessDate              != source.ProcessDate
THEN UPDATE
    SET target.StoreNumber              = source.StoreNumber,
        target.TransactionCentury       = source.TransactionCentury,
        target.TransactionDate          = source.TransactionDate,
        target.RegisterNumber           = source.RegisterNumber,
        target.RollOverNumber           = source.RollOverNumber,
        target.TransactionNumber        = source.TransactionNumber,
        target.TransactionTime          = source.TransactionTime,
        target.TransactionType          = source.TransactionType,
        target.TransactionAmount        = source.TransactionAmount,
        target.TenderAmount             = source.TenderAmount,
        target.STATUS                   = source.Status,
        target.Highlight                = source.Highlight,
        target.CashierNumber            = source.CashierNumber,
        target.TillNumber               = source.TillNumber,
        target.SalespersonNo            = source.SalespersonNo,
        target.AcctType                 = source.AcctType,
        target.AccountNumber            = source.AccountNumber,
        target.ReasonCode               = source.ReasonCode,
        target.OriginalSalesperson      = source.OriginalSalesperson,
        target.OriginalStore            = source.OriginalStore,
        target.CustomerNumber           = source.CustomerNumber,
        target.ProcessDate              = source.ProcessDate
WHEN NOT MATCHED BY TARGET
    THEN INSERT 
        (
            StoreNumber
            , TransactionCentury
            , TransactionDate
            , RegisterNumber
            , RollOverNumber
            , TransactionNumber
            , TransactionTime
            , TransactionType
            , TransactionAmount
            , TenderAmount
            , Status
            , Highlight
            , CashierNumber
            , TillNumber
            , SalespersonNo
            , AcctType
            , AccountNumber
            , ReasonCode
            , OriginalSalesperson
            , OriginalStore
            , CustomerNumber
            , ProcessDate
        ) 
    VALUES 
        (
            source.StoreNumber
            , source.TransactionCentury
            , source.TransactionDate
            , source.RegisterNumber
            , source.RollOverNumber
            , source.TransactionNumber
            , source.TransactionTime
            , source.TransactionType
            , source.TransactionAmount
            , source.TenderAmount
            , source.Status
            , source.Highlight
            , source.CashierNumber
            , source.TillNumber
            , source.SalespersonNo
            , source.AcctType
            , source.AccountNumber
            , source.ReasonCode
            , source.OriginalSalesperson
            , source.OriginalStore
            , source.CustomerNumber
            , source.ProcessDate
        ) 
    ;                                                                                                 
END;                              