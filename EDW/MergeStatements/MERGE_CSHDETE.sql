USE [EDW]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MERGE_CSHDETE]
AS
BEGIN
MERGE EDW.dbo.CSHDETE as target
USING EDW.stg.CSHDETE as source
ON
    (
        target.StoreNumber                      = source.StoreNumber
        and target.TransactionCentury           = source.TransactionCentury
        and target.TransactionDate              = source.TransactionDate
        and target.RegisterNumber               = source.RegisterNumber
        and target.RollOverNumber               = source.RollOverNumber
        and target.TransactionNumber            = source.TransactionNumber
        and target.SequenceNumber               = source.SequenceNumber
        and target.SkuNumber                    = source.SkuNumber
    )
WHEN MATCHED THEN
    UPDATE 
            SET target.StoreNumber              = source.StoreNumber,
                target.TransactionCentury       = source.TransactionCentury,
                target.RegisterNumber           = source.RegisterNumber,
                target.RollOverNumber           = source.RollOverNumber,
                target.TransactionDate          = source.TransactionDate,
                target.TransactionNumber        = source.TransactionNumber,
                target.SequenceNumber           = source.SequenceNumber,
                target.POSDept                  = source.POSDept,
                target.TaxExemptCode            = source.TaxExemptCode,
                target.EventNumber              = source.EventNumber,
                target.BogoGetItem              = source.BogoGetItem,
                target.Last_Modified            = source.Last_Modified
  WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            StoreNumber,
            TransactionCentury,
            TransactionDate,
            RegisterNumber,
            RollOverNumber,
            TransactionNumber,
            SequenceNumber,
            POSDept,
            TaxExemptCode,
            EventNumber,
            BogoGetItem,
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
            source.POSDept,
            source.TaxExemptCode,
            source.EventNumber,
            source.BogoGetItem,
            source.Last_Modified              
        )                  
    ;
END;    