USE SCC
GO

ALTER PROCEDURE dbo.BUILD_CYCLE_COUNT
AS
BEGIN

EXEC
('ALTER VIEW Cycle_Count_Begin 
with schemabinding as
SELECT ScanID,
	BatchNumber,
	BatchPass,
	CAST(RTRIM(SKU) AS INT) AS SKU,
	Manufactures,
	[Description],
	Author,
	Department,
	SubDepartment,
	SubClass,
	StoreNumber,
	ActionAllyPlacement,
	OnHand,
	ScannedCnt,
	RetailPrice,
	CAST(DateCreated as DATE) as Date_Key,
	CAST(DateCreated as TIME) as Scan_Date,
	CreatedBy,
	ItemPosted
FROM dbo.tblScannedItems
UNION ALL
SELECT ScanID,
	BatchNumber,
	BatchPass,
	CAST(RTRIM(SKU) AS INT) AS SKU,
	Manufactures,
	[Description],
	Author,
	Department,
	SubDepartment,
	SubClass,
	StoreNumber,
	ActionAllyPlacement,
	OnHand,
	ScannedCnt,
	RetailPrice,
	CAST(DateCreated as DATE) as Date_Key,
	CAST(DateCreated as TIME) as Scan_Date,
	CreatedBy,
	ItemPosted
FROM dbo.tblScannedItems_Arch')

/**Next create a view of what is a second step refining the datapoints required for the final report****/

EXEC
('ALTER VIEW Cycle_Count_Midway
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
	, ''Y'' as TEMP
FROM dbo.Cycle_Count_Begin
WHERE CreatedBy != ''BAM\Kennedyl''')

EXEC
('ALTER VIEW dbo.LEFTY
WITH SCHEMABINDING AS
SELECT BatchNumber
	, SKU
	, StoreNumber
	, MIN(BatchPass) as Initial_Pass
	, MAX(BatchPass) as Variance_Pass
	, CAST(MIN(Scan_date) as TIME) as Initial_Scan_Date
	, CAST(MAX(Scan_date) as DATE) as Variance_Scan_Date
	, CAST(MIN(Date_Key) as DATE) as Initial_Date
	, CAST(MAX(Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT BatchPass) as Number_of_Counts
FROM dbo.Cycle_Count_Midway
GROUP BY BatchNumber,SKU,StoreNumber')


SELECT a.BatchNumber as Batch_Number
	, a.SKU
	, a.StoreNumber as Store_Number
	, a.OnHand as MMS_Qty
	, a.ScannedCnt as Count_Qty
	, a.BatchPass
	, a.StoreNumber as StoreKey
	, a.SKU as ItemKey
	, a.Date_Key
	, b.Variance_Date as Scan_Date
	, b.Variance_Scan_Date as Scan_Tmstmp
	, 'Variance Count' as Count_Type
FROM Cycle_Count_Midway a
LEFT JOIN LEFTY b
ON a.SKU = b.SKU
WHERE (BatchPass=Variance_Pass and Scan_Date=Variance_Scan_Date and Number_of_Counts=2) or (BatchPass=Variance_Pass and BatchPass > 2 and Number_of_Counts=1)

UNION ALL

SELECT a.BatchNumber as Batch_Number
	, a.SKU
	, a.StoreNumber as Store_Number
	, a.OnHand as MMS_Qty
	, a.ScannedCnt as Count_Qty
	, a.BatchPass
	, a.StoreNumber as StoreKey
	, a.SKU as ItemKey
	, a.Date_Key
	, b.Variance_Date as Scan_Date
	, b.Variance_Scan_Date as Scan_Tmstmp
	, 'Initial Count' as Count_Type
FROM Cycle_Count_Midway a
LEFT JOIN LEFTY b
ON CAST(a.SKU AS INT) = CAST(b.SKU AS INT)
WHERE (BatchPass=Initial_Pass and Scan_date=CAST(Initial_Scan_Date AS DATETIME) and Number_of_Counts=1 and BatchPass<3) 

End;