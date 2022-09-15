ALTER PROCEDURE dbo.MERGE_CSHRED
AS
BEGIN
MERGE EDW.dbo.CSHRED as target 
USING EDW.stg.CSHRED as source
ON
    (
        target.StoreNumber              = source.StoreNumber
        and target.TransactionCentury   = source.TransactionCentury
        and target.TransactionDate      = source.TransactionDate
        and target.RegisterNumber       = source.RegisterNumber
        and target.TillNumber           = source.TillNumber
        and target.ReportLineNo         = source.ReportLineNo
        and target.DepartmentNo         = source.DepartmentNo
        and target.ReportAmount         = source.ReportAmount
    )
WHEN MATCHED
    THEN UPDATE
        SET target.StoreNumber          = source.StoreNumber,
            target.TransactionCentury   = source.TransactionCentury,
            target.TransactionDate      = source.TransactionDate,
            target.RegisterNumber       = source.RegisterNumber,
            target.TillNumber           = source.TillNumber,
            target.ReportLineNo         = source.ReportLineNo,
            target.DepartmentNo         = source.DepartmentNo,
            target.ReportAmount         = source.ReportAmount
WHEN NOT MATCHED BY TARGET 
            THEN INSERT
            (
                StoreNumber,
                TransactionCentury,
                TransactionDate,
                RegisterNumber,
                TillNumber,
                ReportLineNo,
                DepartmentNo,
                ReportAmount  
            )            
        VALUES
            (
                source.StoreNumber,
                source.TransactionCentury,
                source.TransactionDate,
                source.RegisterNumber,
                source.TillNumber,
                source.ReportLineNo,
                source.DepartmentNo,
                source.ReportAmount  
            )    
    ;
END;    