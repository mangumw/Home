ALTER PROCEDURE dbo.MERGE_CSRSV
AS
BEGIN
MERGE EDW.dbo.CSRSV as target
USING EDW.stg.CSRSV as source
ON
    (
        target.CustomerNumber           = source.CustomerNumber
        AND target.ItemNumber           = source.ItemNumber
    )
WHEN MATCHED   
    AND target.QuantityReserved         != source.QuantityReserved
    OR  target.[ExpireDate]             != source.ExpireDate
    OR  target.LastMaintTime            != source.LastMaintTime
THEN UPDATE 
    SET target.CompanyNumber            = source.CompanyNumber,
        target.CustomerNumber           = source.CustomerNumber,
        target.WarehouseID              = source.WarehouseID,
        target.ItemNumber               = source.ItemNumber,
        target.QuantityReserved         = source.QuantityReserved,
        target.UnitofMeasure            = source.UnitofMeasure,
        target.ExpireDateCnty           = source.ExpireDateCnty,
        target.[ExpireDate]             = source.ExpireDate,
        target.LastMaintDateCnty        = source.LastMaintDateCnty,
        target.LastMaintDate            = source.LastMaintDate,
        target.LastMaintUser            = source.LastMaintUser,
        target.LastMaintTime            = source.LastMaintTime,
        target.Last_Modified            = source.Last_Modified
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            CompanyNumber,
            CustomerNumber,
            WarehouseID,
            ItemNumber,
            QuantityReserved,
            UnitofMeasure,
            ExpireDateCnty,
            ExpireDate,
            LastMaintDateCnty,
            LastMaintDate,
            LastMaintUser,
            LastMaintTime,
            Last_Modified 
        )
    VALUES
        (
            source.CompanyNumber,
            source.CustomerNumber,
            source.WarehouseID,
            source.ItemNumber,
            source.QuantityReserved,
            source.UnitofMeasure,
            source.ExpireDateCnty,
            source.ExpireDate,
            source.LastMaintDateCnty,
            source.LastMaintDate,
            source.LastMaintUser,
            source.LastMaintTime,
            source.Last_Modified 
        )  
    ;
END;          