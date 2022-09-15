USE EDW
GO

ALTER PROCEDURE dbo.MERGE_RTVTRN
AS
BEGIN
MERGE EDW.dbo.RTVTRN as target
USING EDW.stg.RTVTRN as source
ON
    (
        target.StoreNumber                          = source.StoreNumber
        and target.SkuNumber                        = source.SkuNumber
        and target.VendorNumber                     = source.VendorNumber
        and target.ScanCode                         = source.ScanCode
        and target.CreateDate                       = source.CreateDate
        and target.DebitNumber                      = source.DebitNumber
    )
WHEN MATCHED THEN
    UPDATE 
        SET target.DebitNumber                      = source.DebitNumber,
            target.StoreNumber                      = source.StoreNumber,
            target.VendorNumber                     = source.VendorNumber,
            target.ScanCode                         = source.ScanCode,
            target.SkuNumber                        = source.SkuNumber,
            target.Dept                             = source.Dept,
            target.MMSOnHand                        = source.MMSOnHand,
            target.SKUStatus                        = source.SKUStatus,
            target.SkuType                          = source.SkuType,
            target.StoreQtyReturned                 = source.StoreQtyReturned,
            target.QuantityReturned                 = source.QuantityReturned,
            target.DateReturned                     = source.DateReturned,
            target.TimeReturned                     = source.TimeReturned,
            target.StatusFlag                       = source.StatusFlag,
            target.CreateDate                       = source.CreateDate,
            target.CreateUser                       = source.CreateUser,
            target.CreateProgram                    = source.CreateProgram,
            target.ChangeDate                       = source.ChangeDate,
            target.ChangeUser                       = source.ChangeUser,
            target.ChangeProgram                    = source.ChangeProgram,
            target.StatementField                   = source.StatementField,
            target.ReconciledDate                   = source.ReconciledDate,
            target.LastRecvQty                      = source.LastRecvQty,
            target.DateLastMaint                    = source.DateLastMaint,
            target.Last_Modified                    = source.Last_Modified
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            DebitNumber,
            StoreNumber,
            VendorNumber,
            ScanCode,
            SkuNumber,
            Dept,
            MMSOnHand,
            SKUStatus,
            SkuType,
            StoreQtyReturned,
            QuantityReturned,
            DateReturned,
            TimeReturned,
            StatusFlag,
            CreateDate,
            CreateUser,
            CreateProgram,
            ChangeDate,
            ChangeUser,
            ChangeProgram,
            StatementField,
            ReconciledDate,
            LastRecvQty,
            DateLastMaint,
            Last_Modified            
        )  
    VALUES
        (
            source.DebitNumber,
            source.StoreNumber,
            source.VendorNumber,
            source.ScanCode,
            source.SkuNumber,
            source.Dept,
            source.MMSOnHand,
            source.SKUStatus,
            source.SkuType,
            source.StoreQtyReturned,
            source.QuantityReturned,
            source.DateReturned,
            source.TimeReturned,
            source.StatusFlag,
            source.CreateDate,
            source.CreateUser,
            source.CreateProgram,
            source.ChangeDate,
            source.ChangeUser,
            source.ChangeProgram,
            source.StatementField,
            source.ReconciledDate,
            source.LastRecvQty,
            source.DateLastMaint,
            source.Last_Modified               
        )          
    ;
END;                