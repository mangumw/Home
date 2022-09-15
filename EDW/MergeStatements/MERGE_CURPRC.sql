CREATE PROCEDURE dbo.MERGE_CURPRC
AS
BEGIN
MERGE EDW.dbo.CURPRC as target
USING EDW.stg.CURPRC as source
ON
        (
            target.StoreNumber                  = source.StoreNumber
            and target.SkuNumber                = source.SkuNumber
            and target.ISBN                     = source.ISBN
        )
WHEN MATCHED THEN
    UPDATE 
        SET target.StoreNumber                  = source.StoreNumber,
            target.SkuNumber                    = source.SkuNumber,
            target.ISBN                         = source.ISBN,
            target.Department                   = source.Department,
            target.SubDepartment                = source.SubDepartment,
            target.Class                        = source.Class,
            target.SubClass                     = source.SubClass,
            target.CurRegUnitPrice              = source.CurRegUnitPrice,
            target.RegularMult                  = source.RegularMult,
            target.CurPOSUnitPrice              = source.CurPOSUnitPrice,
            target.POSMultiple                  = source.POSMultiple,
            target.CurrentCost                  = source.CurrentCost,
            target.CenturyLastMaint             = source.CenturyLastMaint,
            target.DateLastMaint                = source.DateLastMaint,
            target.Last_Modified                = source.Last_Modified 
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            StoreNumber,
            SkuNumber,
            ISBN,
            Department,
            SubDepartment,
            Class,
            SubClass,
            CurRegUnitPrice,
            RegularMult,
            CurPOSUnitPrice,
            POSMultiple,
            CurrentCost,
            CenturyLastMaint,
            DateLastMaint,
            Last_Modified 
        )  
    VALUES
        (
            source.StoreNumber,
            source.SkuNumber,
            source.ISBN,
            source.Department,
            source.SubDepartment,
            source.Class,
            source.SubClass,
            source.CurRegUnitPrice,
            source.RegularMult,
            source.CurPOSUnitPrice,
            source.POSMultiple,
            source.CurrentCost,
            source.CenturyLastMaint,
            source.DateLastMaint,
            source.Last_Modified 
        )   
    ;
END;         
