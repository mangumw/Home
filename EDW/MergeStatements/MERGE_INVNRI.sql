ALTER PROCEDURE dbo.MERGE_INVNRI
AS
BEGIN
MERGE EDW.dbo.INVNRI as target
USING EDW.stg.INVNRI as source
ON
    (
        target.SkuNumber                = source.SkuNumber
        and target.DWItemNumber         = source.DWItemNumber
    )
WHEN MATCHED
    THEN UPDATE
        SET target.ReasonCode           = source.ReasonCode,
            target.SkuNumber            = source.SkuNumber,
            target.DWItemNumber         = source.DWItemNumber,
            target.ActiveFlag           = source.ActiveFlag,
            target.ProgramName          = source.ProgramName,
            target.[User]               = source.[User],
            target.LastUpdateCentury    = source.LastUpdateCentury,
            target.LastUpdateDate       = source.LastUpdateDate,
            target.LastUpdateTime       = source.LastUpdateTime
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            ReasonCode,
            SkuNumber,
            DWItemNumber,
            ActiveFlag,
            ProgramName,
            [User],
            LastUpdateCentury,
            LastUpdateDate,
            LastUpdateTime 
        )  
    VALUES
        (
            source.ReasonCode,
            source.SkuNumber,
            source.DWItemNumber,
            source.ActiveFlag,
            source.ProgramName,
            source.[User],
            source.LastUpdateCentury,
            source.LastUpdateDate,
            source.LastUpdateTime 
        )    
    ;
END;   