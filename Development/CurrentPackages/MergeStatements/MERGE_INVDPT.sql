CREATE PROCEDURE dbo.MERGE_INVDPT
AS 
BEGIN
MERGE EDW.dbo.INVDPT as target 
USING EDW.stg.INVDPT as source
ON
    (
        target.DepartmentNo                 = source.DepartmentNo
        AND target.SubDeptNo                = source.SubDeptNo
        AND target.ProductClass             = source.ProductClass 
        AND target.SubClass                 = source.SubClass
    )
WHEN MATCHED
    THEN UPDATE     
        SET target.DepartmentNo             = source.DepartmentNo ,
            target.SubDeptNo                = source.SubDeptNo,
            target.ProductClass             = source.ProductClass,
            target.SubClass                 = source.SubClass,
            target.Name                     = source.Name,
            target.ShortName                = source.ShortName,
            target.CommisionPlan            = source.CommisionPlan,
            target.Buyer                    = source.Buyer,
            target.ResponsibleLevel         = source.ResponsibleLevel,
            target.SummaryLevel             = source.SummaryLevel,
            target.SummaryFrequency         = source.SummaryFrequency,
            target.DailyRetention           = source.DailyRetention,
            target.WeeklyRetention          = source.WeeklyRetention,
            target.PeriodRetention          = source.PeriodRetention,
            target.YearlyRetention          = source.YearlyRetention,
            target.ArthurSubclass           = source.ArthurSubclass
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
            DepartmentNo,
            SubDeptNo,
            ProductClass,
            SubClass,
            Name,
            ShortName,
            CommisionPlan,
            Buyer,
            ResponsibleLevel,
            SummaryLevel,
            SummaryFrequency,
            DailyRetention,
            WeeklyRetention,
            PeriodRetention,
            YearlyRetention,
            ArthurSubclass 
        )
    VALUES
        (
            source.DepartmentNo,
            source.SubDeptNo,
            source.ProductClass,
            source.SubClass,
            source.Name,
            source.ShortName,
            source.CommisionPlan,
            source.Buyer,
            source.ResponsibleLevel,
            source.SummaryLevel,
            source.SummaryFrequency,
            source.DailyRetention,
            source.WeeklyRetention,
            source.PeriodRetention,
            source.YearlyRetention,
            source.ArthurSubclass 
        )
    ;
END;