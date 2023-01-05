USE SCC
GO

--DECLARE @Startdate date = '20200101', 
--        @Enddate   date = '20220131';

; WITH one AS
(
SELECT ScanID,
	BatchNumber,
	BatchPass,
	CAST(RTRIM(SKU) AS INT) AS SKU,
	Manufactures,
	Description,
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
	CAST(DateCreated as TIME) as Scan_date,
	CreatedBy,
	ItemPosted
FROM SCC.dbo.tblScannedItems
UNION ALL
SELECT ScanID,
	BatchNumber,
	BatchPass,
	CAST(RTRIM(SKU) AS INT) AS SKU,
	Manufactures,
	Description,
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
	CAST(DateCreated as TIME) as Scan_date,
	CreatedBy,
	ItemPosted
FROM SCC.dbo.tblScannedItems_Arch
),
two as
(
SELECT one.BatchNumber as Batch_Number
	, one.SKU
	, one.StoreNumber as Store_Number
	, MIN(one.BatchPass) as Initial_Pass
	, MAX(one.BatchPass) as Variance_Pass
	, CAST(MIN(one.Scan_date) as TIME) as Initial_Scan_Date
	, CAST(MAX(one.Scan_date) as TIME) as Variance_Scan_Date
	, CAST(MIN(one.Date_Key) as DATE) as Initial_Date
	, CAST(MAX(one.Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT one.BatchPass) as Number_of_Counts
	FROM one
	GROUP BY one.BatchNumber,one.SKU,one.StoreNumber, one.Date_Key
),
three as
(
SELECT two.Batch_Number 
	, two.SKU as SKU
	, two.Store_Number
	, one.OnHand as MMS_Qty
	, one.ScannedCnt as Count_Qty
	, one.BatchPass as Batch_Pass
	, two.Store_Number as StoreKey
	, two.SKU as ItemKey
	, one.Date_Key
	, two.Variance_Date as Scan_Date
	, two.Variance_Scan_Date as Scan_Tmstmp
	, 'Variance Count' as Count_Type
FROM one
INNER JOIN two 
ON one.SKU = two.SKU
AND one.BatchNumber = two.Batch_Number
INNER JOIN three 
on one.SKU = two.SKU
AND one.BatchPass = three.Batch_Pass
and one.StoreNumber = two.Store_Number
WHERE (SUM(one.BatchPass)=MAX(two.Variance_Pass) and CAST(MAX(one.Scan_date) as TIME)=CAST(fiver.Scan_Date as TIME) and CAST(two.Number_of_Counts as INT) =2) 
--		or CAST(one.BatchPass as INT) = CAST(two.Variance_Pass as INT)
--		and one.BatchPass > 2
--		and CAST(two.Number_of_Counts as INT) =1)

),
four as
SELECT
    three.Batch_Number,
    three.SKU,
    three.Store_Number,
    three.MMS_Qty,
    three.Count_Qty,
    three.Batch_Pass,
    three.StoreKey,
    three.ItemKey,
    three.Date_Key,
    three.Scan_Date,
    three.Scan_Tmstmp,
    'Initial Count' as Count_Type
FROM one
INNER JOIN two 
ON one.SKU = two.SKU
AND one.BatchNumber = two.Batch_Number
INNER JOIN three 
on one.SKU = two.SKU
AND one.BatchPass = three.Batch_Pass
and one.StoreNumber = two.Store_Number	
WHERE (two.Batch_Pass=Initial_Pass and Scan_date=Initial_Scan_Date and Number_of_Counts=1 and BatchPass<3) 
