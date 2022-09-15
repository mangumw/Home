USE SCC
GO

CREATE VIEW Cycle_Count_Midway
WITH SCHEMABINDING AS
SELECT ScanID
	, BatchNumber
	, BatchPass
	, SKU
	, SKU as ItemKey
	, StoreNumber
	, ActionAllyPlacement
	, OnHand 
	, ScannedCnt
	, RetailPrice 
	, CAST(Date_Key as DATE) as Date_Key
	, CAST(Date_Key as DATETIME) as Scan_Date
    , CreatedBy
	, ItemPosted
	, 'Y' as TEMP
FROM dbo.Cycle_Count_Begin
WHERE CreatedBy != 'BAM\Kennedyl'