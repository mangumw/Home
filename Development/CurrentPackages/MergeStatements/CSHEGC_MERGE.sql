ALTER PROCEDURE dbo.MERGE_CSHEGC
AS
BEGIN
merge EDW.dbo.cshegc as target
using EDW.stg.cshegc as source
on (    
        target.StoreNumber              = source.StoreNumber
        and target.TransactionDate      = source.TransactionDate
        and target.RegisterNumber       = source.RegisterNumber
        and target.RollOverNumber       = source.RollOverNumber
        and target.TransactionType      = source.TransactionType
        and target.ExtendedAmount       = source.ExtendedAmount
	    and target.TransactionNumber    = source.TransactionNumber
		and target.SequenceNumber       = source.SequenceNumber
  	)
when matched 
	and target.TransactionDate			!= source.TransactionDate
	or target.RegisterNumber			!= source.RegisterNumber
	or target.RollOverNumber		    != source.RollOverNumber
	or target.TransactionNumber			!= source.TransactionNumber
	or target.SequenceNumber			!= source.SequenceNumber
	or target.TransactionType		    != source.TransactionType
	or target.ExtendedAmount			!= source.ExtendedAmount
	or target.GiftCardNumber		    != source.GiftCardNumber
	or target.GCAuthCode			    != source.GCAuthCode
	or target.DateCreated			    != source.DateCreated
	or target.ProgramName			    != source.ProgramName
then update
	set target.StoreNumber              = source.StoreNumber, 
        target.TransactionDate			= source.TransactionDate,
        target.RegisterNumber			= source.RegisterNumber,
        target.RollOverNumber		    = source.RollOverNumber,
        target.TransactionNumber		= source.TransactionNumber,
        target.SequenceNumber			= source.SequenceNumber,
        target.TransactionType		    = source.TransactionType,
        target.ExtendedAmount			= source.ExtendedAmount,
        target.GiftCardNumber		    = source.GiftCardNumber,
        target.GCAuthCode			    = source.GCAuthCode,
        target.DateCreated			    = source.DateCreated,
        target.ProgramName			    = source.ProgramName,
        target.Last_Modified                        = source.Last_Modified
 WHEN NOT MATCHED BY TARGET
    THEN INSERT (StoreNumber, TransactionDate, RegisterNumber, RollOverNumber, TransactionNumber, SequenceNumber
                , TransactionType, ExtendedAmount, GiftCardNumber, GCAuthCode, DateCreated, ProgramName, Last_Modified)   
        VALUES (source.StoreNumber, source.TransactionDate, source.RegisterNumber, source.RollOverNumber, source.TransactionNumber, source.SequenceNumber
                , source.TransactionType, source.ExtendedAmount, source.GiftCardNumber, source.GCAuthCode, source.DateCreated, source.ProgramName, source.Last_Modified)
	; 
END;