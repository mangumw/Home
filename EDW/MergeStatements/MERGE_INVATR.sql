ALTER PROCEDURE dbo.MERGE_INVATR
AS
BEGIN
MERGE EDW.dbo.INVATR as target
USING EDW.stg.INVATR as source
ON
    (
        target.SkuNumber                    = source.SkuNumber
    )
WHEN MATCHED THEN
    UPDATE 
        SET target.SkuNumber                = source.SkuNumber,
            target.Attribute                = source.Attribute,
            target.[Value]                  = source.[Value],    
            target.DateLastMaint            = source.DateLastMaint,
            target.Last_Modified            = source.Last_Modified
 WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            SkuNumber,
            Attribute,
            [Value],
            DateLastMaint,
            Last_Modified 
        )      
    VALUES
        (
            source.SkuNumber,
            source.Attribute,
            source.[Value],
            source.DateLastMaint,
            source.Last_Modified 
        )
    ;
END;    