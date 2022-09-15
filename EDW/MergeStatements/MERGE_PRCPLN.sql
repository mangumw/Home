USE EDW
GO

ALTER PROCEDURE dbo.MERGE_PRCPLN
AS
BEGIN
MERGE EDW.dbo.PRCPLN as target
USING EDW.stg.PRCPLN as source
ON
    (
            target.ItemNumber                       = source.ItemNumber
            and target.ItemNumber                   = source.ItemNumber
            and target.ChangeCodeLevel              = source.ChangeCodeLevel
            and target.StoreNumber                  = source.StoreNumber
            and target.StoreNumber                  = source.StoreNumber
            and target.StoreNumber                  = source.StoreNumber
            and target.VendorNumber                 = source.VendorNumber
            and target.StyleNumber                  = source.StyleNumber
            and target.StartDateCentCode            = source.StartDateCentCode
            and target.TheEffectiveDatePriceChange  = source.TheEffectiveDatePriceChange
            and target.ThePriceEventType            = source.ThePriceEventType
            and target.ISCurrentStatus              = source.ISCurrentStatus
            and target.PriceEventNo                 = source.PriceEventNo
            and target.NewPrice                     = source.NewPrice
            and target.PriceMultiple                = source.PriceMultiple
            and target.MixMatchGroup                = source.MixMatchGroup
            and target.BuyQuantity                  = source.BuyQuantity
            and target.BuyValue                     = source.BuyValue
            and target.BuyValueType                 = source.BuyValueType
            and target.QtyEndValue                  = source.QtyEndValue
            and target.QuantityBreak                = source.QuantityBreak
            and target.EndDateCentCode              = source.EndDateCentCode
            and target.EndingDatePricingRecord      = source.EndingDatePricingRecord
            and target.RecordType                   = source.RecordType
            and target.IsProcessed                  = source.IsProcessed
            and target.IsHistory                    = source.IsHistory
            and target.NotifyStartCentCode          = source.NotifyStartCentCode
            and target.NotifyStartDate              = source.NotifyStartDate
            and target.NotifyEndEndCent             = source.NotifyEndEndCent
            and target.NotifyEndDate                = source.NotifyEndDate
            and target.ApplyCSDOverAD               = source.ApplyCSDOverAD
            and target.ApplyLocOverrideAD           = source.ApplyLocOverrideAD
            and target.Last_Modified                = source.Last_Modified 

    )
WHEN MATCHED
    THEN UPDATE
        SET target.ItemNumber                   = source.ItemNumber,
            target.ChangeCodeLevel              = source.ChangeCodeLevel,
            target.StoreNumber                  = source.StoreNumber,
            target.VendorNumber                 = source.VendorNumber,
            target.StyleNumber                  = source.StyleNumber,
            target.StartDateCentCode            = source.StartDateCentCode,
            target.TheEffectiveDatePriceChange  = source.TheEffectiveDatePriceChange,
            target.ThePriceEventType            = source.ThePriceEventType,
            target.ISCurrentStatus              = source.ISCurrentStatus,
            target.PriceEventNo                 = source.PriceEventNo,
            target.NewPrice                     = source.NewPrice,
            target.PriceMultiple                = source.PriceMultiple,
            target.MixMatchGroup                = source.MixMatchGroup,
            target.BuyQuantity                  = source.BuyQuantity,
            target.BuyValue                     = source.BuyValue,
            target.BuyValueType                 = source.BuyValueType,
            target.QtyEndValue                  = source.QtyEndValue,
            target.QuantityBreak                = source.QuantityBreak,
            target.EndDateCentCode              = source.EndDateCentCode,
            target.EndingDatePricingRecord      = source.EndingDatePricingRecord,
            target.RecordType                   = source.RecordType,
            target.IsProcessed                  = source.IsProcessed,
            target.IsHistory                    = source.IsHistory,
            target.NotifyStartCentCode          = source.NotifyStartCentCode,
            target.NotifyStartDate              = source.NotifyStartDate,
            target.NotifyEndEndCent             = source.NotifyEndEndCent,
            target.NotifyEndDate                = source.NotifyEndDate,
            target.ApplyCSDOverAD               = source.ApplyCSDOverAD,
            target.ApplyLocOverrideAD           = source.ApplyLocOverrideAD,
            target.Last_Modified                = source.Last_Modified 
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            ItemNumber,
            ChangeCodeLevel,
            StoreNumber,
            VendorNumber,
            StyleNumber,
            StartDateCentCode,
            TheEffectiveDatePriceChange,
            ThePriceEventType, 
            ISCurrentStatus, 
            PriceEventNo,
            NewPrice,
            PriceMultiple,
            MixMatchGroup,
            BuyQuantity,
            BuyValue,
            BuyValueType,
            QtyEndValue,
            QuantityBreak,
            EndDateCentCode,
            EndingDatePricingRecord,
            RecordType,
            IsProcessed,
            IsHistory,
            NotifyStartCentCode,
            NotifyStartDate,
            NotifyEndEndCent,
            NotifyEndDate,
            ApplyCSDOverAD,
            ApplyLocOverrideAD,
            Last_Modified             
        ) 
    VALUES
        (
            source.ItemNumber,
            source.ChangeCodeLevel,
            source.StoreNumber,
            source.VendorNumber,
            source.StyleNumber,
            source.StartDateCentCode,
            source.TheEffectiveDatePriceChange,
            source.ThePriceEventType, 
            source.ISCurrentStatus, 
            source.PriceEventNo,
            source.NewPrice,
            source.PriceMultiple,
            source.MixMatchGroup,
            source.BuyQuantity,
            source.BuyValue,
            source.BuyValueType,
            source.QtyEndValue,
            source.QuantityBreak,
            source.EndDateCentCode,
            source.EndingDatePricingRecord,
            source.RecordType,
            source.IsProcessed,
            source.IsHistory,
            source.NotifyStartCentCode,
            source.NotifyStartDate,
            source.NotifyEndEndCent,
            source.NotifyEndDate,
            source.ApplyCSDOverAD,
            source.ApplyLocOverrideAD,
            source.Last_Modified               
        )               
    ;
END;        