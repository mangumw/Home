DECLARE @Start as DATETIME
DECLARE @End as DATETIME

SET @Start = ISNULL(@Start,'2022-03-01')
SET @End = ISNULL(@End, '2022-03-31')

;WITH CTE AS
(
SELECT
	a.ScanID, 
	a.BatchNumber, 
	a.BatchPass, 
	a.SKU, 
    a.SKU as ItemKey,
	a.StoreNumber,
	a.ActionAllyPlacement, 
	a.OnHand, 
	a.ScannedCnt, 
	a.RetailPrice, 
	a.DateCreated,
    a.CreatedBy,
    CAST(a.DateCreated as DATE) as Date_Key,
    CAST(a.DateCreated as DATETIME) as Scan_Date,
	a.ItemPosted,
    'Y' as TEMP
FROM SCC.dbo.tblScannedItems a
WHERE CreatedBy != 'BAM\kennedyl'
UNION ALL
SELECT
	a.ScanID, 
	a.BatchNumber, 
	a.BatchPass, 
	a.SKU, 
    a.SKU as ItemKey,
	a.StoreNumber,
	a.ActionAllyPlacement, 
	a.OnHand, 
	a.ScannedCnt, 
	a.RetailPrice, 
	a.DateCreated,
    a.CreatedBy,
    CAST(a.DateCreated as DATE) as Date_Key,
    CAST(a.DateCreated as DATETIME) as Scan_Date,
	a.ItemPosted,
    'Y' as TEMP
FROM SCC.dbo.tblScannedItems_Arch a
WHERE CreatedBy != 'BAM\kennedyl'
),
CTE2 as
(
SELECT BatchNumber
	, SKU
	, StoreNumber
	, MIN(BatchPass) as Initial_Pass
	, MAX(BatchPass) as Variance_Pass
	, CAST(MIN(Scan_date) as DATE) as Initial_Scan_Date
	, CAST(MAX(Scan_date) as DATE) as Variance_Scan_Date
	, CAST(MIN(Date_Key) as DATE) as Initial_Date
	, CAST(MAX(Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT BatchPass) as Number_of_Counts
FROM CTE a
GROUP BY BatchNumber,SKU,StoreNumber
),
CTE3 as
(
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
FROM CTE a
LEFT JOIN CTE2 b
ON a.SKU = b.SKU
WHERE (a.BatchPass=b.Variance_Pass 
and a.Scan_Date=b.Variance_Scan_Date 
and b.Number_of_Counts=2) 
or (a.BatchPass=b.Variance_Pass 
and a.BatchPass > 2 
and b.Number_of_Counts=1)
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
FROM CTE a
LEFT JOIN CTE2 b
ON a.SKU = b.SKU
WHERE (a.BatchPass=b.Initial_Pass 
AND CAST(a.Scan_date as DATE)=CAST(b.Initial_Scan_Date as DATE)
AND b.Number_of_Counts=1 
AND a.BatchPass<3) 
)
SELECT DISTINCT c.Batch_Number
	, c.SKU
	, c.Store_Number
	, c.MMS_Qty
	, c.Count_Qty
	, c.BatchPass
	, c.StoreKey as Store_Key
	, c.ItemKey as Item_Key
	, c.Date_Key
	, c.Scan_Date
	, c.Scan_Tmstmp
	, c.Count_Type
FROM CTE a
LEFT JOIN CTE2 b
ON a.SKU = b.SKU
INNER JOIN CTE3 c
ON a.SKU = c.SKU
WHERE 
	convert(DATE, c.Date_Key, 101) >= @Start 
AND convert(DATE, c.Date_Key, 101) <= @End
ORDER BY c.Date_Key DESC
