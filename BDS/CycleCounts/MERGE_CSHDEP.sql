ALTER PROCEDURE dbo.MERGE_CSHDEP
AS
BEGIN
MERGE EDW.dbo.CSHDEP as target 
USING EDW.stg.CSHDEP as source
ON
    (
        target.StoreNumber                      = source.StoreNumber
        and target.DepositCentury               = source.DepositCentury
        and target.DepositDate                  = source.DepositDate
        and target.RegisterNumber               = source.RegisterNumber
        and target.TillNumber                   = source.TillNumber        
        and target.ReportLineNo                 = source.ReportLineNo
        and target.DepositAmount                = source.DepositAmount

    )
 WHEN MATCHED
    THEN UPDATE 
        SET target.StoreNumber                  = source.StoreNumber,
            target.DepositCentury               = source.DepositCentury,
            target.DepositDate                  = source.DepositDate,
            target.RegisterNumber               = source.RegisterNumber,
            target.TillNumber                   = source.TillNumber,
            target.ReportLineNo                 = source.ReportLineNo,
            target.DepositAmount                = source.DepositAmount,
            target.Last_Modified                = source.Last_Modified
WHEN NOT MATCHED BY TARGET THEN
        INSERT  
            (
                StoreNumber,
                DepositCentury,
                DepositDate,
                RegisterNumber,
                TillNumber,
                ReportLineNo,
                DepositAmount,
                Last_Modified 
            )   
        VALUES
            (
                source.StoreNumber,
                source.DepositCentury,
                source.DepositDate,
                source.RegisterNumber,
                source.TillNumber,
                source.ReportLineNo,
                source.DepositAmount,
                source.Last_Modified 
            )                
    ;
END;   


