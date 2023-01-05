USE SCC
GO

--DECLARE @Startdate date = '20200101', 
--        @Enddate   date = '20220131';

;WITH one(ScanID, BatchNumber, BatchPass, SKU, Manufactures, [[Description]], Author, Department, SubDepartment, SubClass, StoreNumber
		, ActionAllyPlacement, OnHand, ScannedCnt, RetailPrice, Date_Key, Scan_Date, CreatedBy, ItemPosted) AS
(
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
FROM SCC.dbo.tblScannedItems
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
FROM SCC.dbo.tblScannedItems_Arch
),
two as
(
SELECT one.BatchNumber as Batch_Number
	, one.SKU
	, one.StoreNumber as Store_Number
	, MIN(one.BatchPass) as Initial_Pass
	, MAX(one.BatchPass) as Variance_Pass
	, CAST(MIN(one.Scan_Date) as TIME) as Initial_Scan_Date
	, CAST(MAX(one.Scan_Date) as TIME) as Variance_Scan_Date
	, CAST(MIN(one.Date_Key) as DATE) as Initial_Date
	, CAST(MAX(one.Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT one.BatchPass) as Number_of_Counts
	FROM one
--	GROUP BY one.BatchNumber,one.SKU,one.StoreNumber
),
three as
(
Select 
	two.Batch_Number
	, two.SKU
	, two.Store_Number
	, one.OnHand as MMS_Qty
	, one.ScannedCnt as Count_Qty
	, one.BatchPass
	, one.StoreNumber
	, two.SKU as ItemKey
	, one.Date_Key
	, two.Variance_Date as Scan_Tmstmp
	, 'Variance Count' as Count_Type
from one
inner join two
on one.SKU = two.SKU
WHERE (one.BatchPass = two.Variance_Pass and one.Scan_Date = two.Variance_Scan_Date and two.Number_of_Counts = 2)
	or (one.BatchPass = two.Variance_Pass and one.BatchPass > 2 and two.Number_of_Counts = 1)
),
four as
(
SELECT
	three.Batch_Number
	, three.SKU 
	, three.Store_Number
	, three.MMS_Qty
	, three.Count_Qty
	, three.BatchPass
	, three.Store_Number as StoreKey
	, three.SKU as ItemKey
	, three.Date_Key
	, two.Initial_Scan_Date as Scan_Tmstmp
	,'Initial Count' as Count_Type
FROM one
INNER JOIN two
ON one.SKU = two.SKU
LEFT JOIN three
ON three.SKU = one.SKU
WHERE (one.BatchPass = two.Initial_Pass and one.Scan_Date = two.Initial_Scan_Date and two.Number_of_Counts = 1 and one.BatchPass < 3)
)
SELECT DISTINCT one.SKU, two.SKU, three.SKU
FROM one 
INNER JOIN two
on one.SKU = two.SKU
LEFT JOIN three
ON three.SKU = d.SKU
OPTION (MAXRECURSION 2)