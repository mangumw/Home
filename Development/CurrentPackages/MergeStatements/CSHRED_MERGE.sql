ALTER PROCEDURE dbo.MERGE_CSHRED
AS
BEGIN
MERGE EDW.dbo.CSHRED AS target
USING EDW.stg.CSHRED AS source
ON
	(
			target.StoreNumber		= source.StoreNumber
		AND target.TransactionDate	= source.TransactionDate
		AND target.RegisterNumber	= source.RegisterNumber
		AND target.TillNumber		= source.TillNumber
		AND target.ReportLineNo		= source.ReportLineNo
		AND target.DepartmentNo		= source.DepartmentNo
		AND target.ReportAmount		= source.ReportAmount
	)
WHEN MATCHED THEN 
UPDATE
	SET	target.StoreNumber			= source.StoreNumber,
		target.TransactionCentury	= source.TransactionCentury,
		target.TransactionDate		= source.TransactionDate,
		target.RegisterNumber		= source.RegisterNumber,
		target.TillNumber			= source.TillNumber,
		target.ReportLineNo			= source.ReportLineNo,
		target.DepartmentNo			= source.DepartmentNo,
		target.ReportAmount			= source.ReportAmount,
		target.Last_Modified		= source.Last_Modified
WHEN NOT MATCHED BY TARGET
	THEN INSERT (StoreNumber, TransactionCentury, TransactionDate, RegisterNumber,
				TillNumber, ReportLineNo, DepartmentNo, ReportAmount, Last_Modified)
		VALUES (source.StoreNumber, source.TransactionCentury, source.TransactionDate, source.RegisterNumber, 
				source.TillNumber, source.ReportLineNo, source.DepartmentNo, source.ReportAmount, source.Last_Modified)
-- WHEN NOT MATCHED BY SOURCE 
--    THEN DELETE 
	;
END;

