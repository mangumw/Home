CREATE PROCEDURE dbo.MERGE_RDI010
AS
BEGIN
MERGE EDW.dbo.RDI010 as target
USING EDW.stg.RDI010 as source
ON
    (
        target.StoreNumber                      = source.StoreNumber
        and target.SkuNumber                    = source.SkuNumber
        and target.DWItemNumber                 = source.DWItemNumber
    )
WHEN MATCHED THEN
    UPDATE 
        SET target.StoreNumber                  = source.StoreNumber,
            target.SkuNumber                    = source.SkuNumber,
            target.PrimaryISBN                  = source.PrimaryISBN,
            target.DWItemNumber                 = source.DWItemNumber,
            target.StockToQty                   = source.StockToQty,
            target.OnHandQty                    = source.OnHandQty,
            target.SkuStatusCode                = source.SkuStatusCode,
            target.SkuTypeCode                  = source.SkuTypeCode,
            target.SkuReplenCode                = source.SkuReplenCode,
            target.DateCreated                  = source.DateCreated,
            target.Dept                         = source.Dept,
            target.SubDept                      = source.SubDept,
            target.Class                        = source.Class,
            target.SubClass                     = source.SubClass,
            target.Last_Modified                = source.Last_Modified 
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            StoreNumber,
            SkuNumber,
            PrimaryISBN,
            DWItemNumber,
            StockToQty,
            OnHandQty,
            SkuStatusCode,
            SkuTypeCode,
            SkuReplenCode,
            DateCreated,
            Dept,
            SubDept,
            Class,
            SubClass,
            Last_Modified             
        )  
    VALUES
        (
            source.StoreNumber,
            source.SkuNumber,
            source.PrimaryISBN,
            source.DWItemNumber,
            source.StockToQty,
            source.OnHandQty,
            source.SkuStatusCode,
            source.SkuTypeCode,
            source.SkuReplenCode,
            source.DateCreated,
            source.Dept,
            source.SubDept,
            source.Class,
            source.SubClass,
            source.Last_Modified              
        )  
    ;
END;                    