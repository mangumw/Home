USE EDW
GO

ALTER PROCEDURE dbo.MERGE_PIE022
AS
BEGIN
MERGE EDW.dbo.PIE022 as target
USING EDW.stg.PIE022 as source
ON
    (
        target.SkuNumber                    = source.SkuNumber
        and target.StoreNumber              = source.StoreNumber
        and target.CountIDNumber            = source.CountIDNumber
		and target.QtyCounted				= source.QtyCounted
		and target.JDADepartment			= source.JDADepartment
		and target.JDASubDepartment			= source.JDASubDepartment
		and target.JDAClass					= source.JDAClass
		and target.JDASubClass				= source.JDASubClass
    )
WHEN MATCHED
    THEN UPDATE
        SET target.CountIDNumber            = source.CountIDNumber,
            target.StoreNumber              = source.StoreNumber,
            target.SkuNumber                = source.SkuNumber,
            target.QtyCounted               = source.QtyCounted,
            target.JDADepartment            = source.JDADepartment,
            target.JDASubDepartment         = source.JDASubDepartment,
            target.JDAClass                 = source.JDAClass,
            target.JDASubClass              = source.JDASubClass,
            target.BamDepartment            = source.BamDepartment,
            target.BamCategory              = source.BamCategory,
            target.DateCounted              = source.DateCounted,
            target.StockToQty               = source.StockToQty,
            target.OnHandQty                = source.OnHandQty,
            target.RollBackOnHandQty        = source.RollBackOnHandQty,
            target.AdjustmentQty            = source.AdjustmentQty,
            target.DatePosted               = source.DatePosted,
            target.TimePosted               = source.TimePosted,
            target.PostedBy                 = source.PostedBy,
            target.CurrentPrice             = source.CurrentPrice,
            target.SkuType                  = source.SkuType,
            target.SkuStatus                = source.SkuStatus,
            target.DateLastMaint            = source.DateLastMaint,
            target.Last_Modified            = source.Last_Modified 
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            CountIDNumber,
            StoreNumber,
            SkuNumber,
            QtyCounted,
            JDADepartment,
            JDASubDepartment,
            JDAClass,
            JDASubClass,
            BamDepartment,
            BamCategory,
            DateCounted,
            StockToQty,
            OnHandQty,
            RollBackOnHandQty,
            AdjustmentQty,
            DatePosted,
            TimePosted,
            PostedBy,
            CurrentPrice,
            SkuType,
            SkuStatus,
            DateLastMaint,
            Last_Modified             
        )  
    VALUES
        (
            source.CountIDNumber,
            source.StoreNumber,
            source.SkuNumber,
            source.QtyCounted,
            source.JDADepartment,
            source.JDASubDepartment,
            source.JDAClass,
            source.JDASubClass,
            source.BamDepartment,
            source.BamCategory,
            source.DateCounted,
            source.StockToQty,
            source.OnHandQty,
            source.RollBackOnHandQty,
            source.AdjustmentQty,
            source.DatePosted,
            source.TimePosted,
            source.PostedBy,
            source.CurrentPrice,
            source.SkuType,
            source.SkuStatus,
            source.DateLastMaint,
            source.Last_Modified              
        )
    ;
END;                      