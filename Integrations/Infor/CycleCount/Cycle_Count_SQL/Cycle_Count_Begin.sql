USE SCC
GO

create view Cycle_Count_Begin 
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
FROM dbo.tblScannedItems_Arch