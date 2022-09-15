USE [EDW]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MERGE_CSHDISE]
AS
BEGIN
MERGE EDW.dbo.CSHDISE as target
USING EDW.stg.CSHDISE as source
ON
    (
        target.StoreNumber                      = source.StoreNumber
        and target.TransactionNumber            = source.TransactionNumber
    )
WHEN MATCHED THEN
    UPDATE 
            SET target.StoreNumber              = source.StoreNumber,
                target.TransactionCentury       = source.TransactionCentury,
                target.TransactionDate          = source.TransactionDate,
                target.RegisterNumber           = source.RegisterNumber,
                target.RollOverNumber           = source.RollOverNumber,
                target.TransactionNumber        = source.TransactionNumber,
                target.SequenceNumber           = source.SequenceNumber,
                target.DiscountSequenceNumber   = source.DiscountSequenceNumber,
                target.ReasonCode               = source.ReasonCode,
                target.Last_Modified            = source.Last_Modified
 WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
              StoreNumber
            , TransactionCentury
            , TransactionDate
            , RegisterNumber
            , RollOverNumber
            , TransactionNumber
            , SequenceNumber
            , DiscountSequenceNumber
            , ReasonCode
            , Last_Modified           
        )   
    VALUES
        (
              source.StoreNumber
            , source.TransactionCentury
            , source.TransactionDate
            , source.RegisterNumber
            , source.RollOverNumber
            , source.TransactionNumber
            , source.SequenceNumber
            , source.DiscountSequenceNumber
            , source.ReasonCode
            , source.Last_Modified             
        )   
    ;
END;                     