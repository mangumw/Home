ALTER PROCEDURE dbo.MERGE_INVUPCP
AS 
BEGIN
MERGE EDW.dbo.INVUPCP as target 
USING EDW.stg.INVUPCP as source
ON
    (
        target.SkuNumber                    = source.SkuNumber
    )
WHEN MATCHED
    THEN UPDATE
        SET target.UPCNumber                = source.UPCNumber,
            target.UPCType                  = source.UPCType,
            target.SkuNumber                = source.SkuNumber,
            target.StyleNumber              = source.StyleNumber,
            target.StyleVendor              = source.StyleVendor,
            target.VendorPartNo             = source.VendorPartNo,
            target.Vendor                   = source.Vendor,
            target.PrepricedAmount          = source.PrepricedAmount,
            target.PrepricedPercentOff      = source.PrepricedPercentOff,
            target.PrepricedAmtOff          = source.PrepricedAmtOff,
            target.FirstActivityCentury     = source.FirstActivityCentury,
            target.FirstActivityDate        = source.FirstActivityDate,
            target.StatusChangeCentury      = source.StatusChangeCentury,
            target.StatusChangeDate         = source.StatusChangeDate,
            target.Last_Modified            = source.Last_Modified
WHEN NOT MATCHED BY TARGET
        THEN INSERT
        (
            UPCNumber,
            UPCType,
            SkuNumber,
            StyleNumber,
            StyleVendor,
            VendorPartNo,
            Vendor,
            PrepricedAmount,
            PrepricedPercentOff,
            PrepricedAmtOff,
            FirstActivityCentury,
            FirstActivityDate,
            StatusChangeCentury,
            StatusChangeDate,
            Last_Modified           
        )                
    VALUES
        (
            source.UPCNumber,
            source.UPCType,
            source.SkuNumber,
            source.StyleNumber,
            source.StyleVendor,
            source.VendorPartNo,
            source.Vendor,
            source.PrepricedAmount,
            source.PrepricedPercentOff,
            source.PrepricedAmtOff,
            source.FirstActivityCentury,
            source.FirstActivityDate,
            source.StatusChangeCentury,
            source.StatusChangeDate,
            source.Last_Modified   
        )
    ;
END;    