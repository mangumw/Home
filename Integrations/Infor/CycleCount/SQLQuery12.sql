USE SCC
GO

IF OBJECT_ID ('#UN1', 'U') IS NOT NULL
DROP TABLE #UN1;
GO
IF OBJECT_ID ('#UN2', 'U') IS NOT NULL
DROP TABLE #UN2;
GO
IF OBJECT_ID ('#CC1', 'U') IS NOT NULL
DROP TABLE #CC1;
GO
IF OBJECT_ID ('#CC2', 'U') IS NOT NULL
DROP TABLE #CC2;
GO
IF OBJECT_ID ('#CC3', 'U') IS NOT NULL
DROP TABLE #CC3;
GO



SELECT ScanID,
	BatchNumber as Batch_Number,
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
INTO #UN1
FROM SCC.dbo.tblScannedItems
UNION ALL
SELECT ScanID,
	BatchNumber as Batch_Number,
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
FROM SCC.dbo.tblScannedItems_Arch

SELECT #UN1.Batch_Number
	, #UN1.SKU
	, #UN1.StoreNumber as Store_Number
	, MIN(#UN1.BatchPass) as Initial_Pass
	, MAX(#UN1.BatchPass) as Variance_Pass
	, CAST(MIN(#UN1.Scan_Date) as TIME) as Initial_Scan_Date
	, CAST(MAX(#UN1.Scan_Date) as TIME) as Variance_Scan_Date
	, CAST(MIN(#UN1.Date_Key) as DATE) as Initial_Date
	, CAST(MAX(#UN1.Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT #UN1.BatchPass) as Number_of_Counts
	INTO #CC1
	FROM #UN1
	GROUP BY #UN1.Batch_Number,#UN1.SKU,#UN1.StoreNumber

Select 
	#CC1.Batch_Number as Batch_Number
	, #CC1.SKU
	, #CC1.Store_Number
	, #UN1.OnHand as MMS_Qty
	, #UN1.ScannedCnt as Count_Qty
	, #UN1.BatchPass
	, #UN1.StoreNumber
	, #CC1.SKU as ItemKey
	, #UN1.Date_Key
	, #CC1.Variance_Date as Scan_Tmstmp
	, 'Variance Count' as Count_Type
INTO #CC2    
from #UN1
inner join #CC1
on #UN1.SKU = #CC1.SKU
WHERE (#UN1.BatchPass = #CC1.Variance_Pass and #UN1.Scan_Date = #CC1.Variance_Scan_Date and #CC1.Number_of_Counts = 2)
	or (#UN1.BatchPass = #CC1.Variance_Pass and #UN1.BatchPass > 2 and #CC1.Number_of_Counts = 1)


Select 
	#CC1.Batch_Number as Batch_Number
	, #CC1.SKU
	, #CC1.Store_Number
	, #UN1.OnHand as MMS_Qty
	, #UN1.ScannedCnt as Count_Qty
	, #UN1.BatchPass
	, #UN1.StoreNumber
	, #CC1.SKU as ItemKey
	, #UN1.Date_Key
	, #CC1.Variance_Date as Scan_Tmstmp
	, 'Initial Count' as Count_Type
INTO #CC3    
from #UN1
inner join #CC1
on #UN1.SKU = #CC1.SKU
WHERE (#UN1.BatchPass = #CC1.Initial_Pass and #UN1.Scan_Date = #CC1.Initial_Scan_Date and #CC1.Number_of_Counts = 1 and #UN1.BatchPass < 3)  




;WITH CC AS
(
SELECT *
from #UN1
UNION ALL
SELECT *
from #UN2
)
SELECT *
FROM CC
INNER JOIN #CC1
ON CC.SKU = #CC1.SKU
AND cc.StoreNumber = #CC1.Store_Number
AND cc.Batch_Number = #CC1.Batch_Number
WHERE CreatedBy != 'BAM\kennedyl'










