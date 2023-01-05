TMPSQL:
LOAD ScanID, 
	BatchNumber, 
	BatchPass, 
	Num(Trim(SKU))	as SKU, 
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
	DateCreated, 
	CreatedBy, 
	ItemPosted;

SELECT ScanID,
	BatchNumber,
	BatchPass,
	SKU,
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
	DateCreated,
	CreatedBy,
	ItemPosted
FROM SCC.dbo.tblScannedItems;

Concatenate(TMPSQL)
LOAD ScanID, 
	BatchNumber, 
	BatchPass, 
	Num(Trim(SKU))	as SKU, 
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
	DateCreated, 
	CreatedBy, 
	ItemPosted;
SELECT ScanID,
	BatchNumber,
	BatchPass,
	SKU,
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
	DateCreated,
	CreatedBy,
	ItemPosted
FROM SCC.dbo.tblScannedItems_Arch;

Cycle_Count:
LOAD
	ScanID, 
	BatchNumber, 
	BatchPass, 
	SKU, 
    SKU as %itemKey,
	StoreNumber,
	ActionAllyPlacement, 
	OnHand, 
	ScannedCnt, 
	RetailPrice, 
	DateCreated,
    CreatedBy,
    Date(Floor(DateCreated)) as Date_Key,
    Timestamp(DateCreated) as Scan_date,
	ItemPosted,
    'Y' as TEMP
    RESIDENT TMPSQL
    WHERE CreatedBy<>'BAM\kennedyl';
    
    DROP TABLE TMPSQL;
    DROP FIELD TEMP;
    
LEFT JOIN (Cycle_Count)
LOAD
	BatchNumber, 
	SKU, 
    StoreNumber,
    MIN(BatchPass) as Initial_Pass,
    MAX(BatchPass) as Variance_Pass,
    TIMESTAMP(MIN(Scan_date)) as Initial_Scan_Date,
    TIMESTAMP(MAX(Scan_date)) as Variance_Scan_Date,
    DATE(MIN(Date_Key)) as Initial_Date,
    DATE(MAX(Date_Key)) as Variance_Date,
    COUNT(DISTINCT BatchPass) as Number_of_Counts
    RESIDENT Cycle_Count
    GROUP BY BatchNumber,SKU,StoreNumber;
    
Cycle_Count_Final:
LOAD
	BatchNumber as Batch_Number,
    SKU,
    StoreNumber as Store_Number,
    OnHand as MMS_Qty,
    ScannedCnt as Count_Qty,
    BatchPass,
    StoreNumber as %storeKey,
    SKU as %itemKey,
    Date_Key,
    Variance_Date as Scan_Date,
    Variance_Scan_Date as Scan_Tmstmp,
    'Variance Count' as Count_Type
    RESIDENT Cycle_Count
    WHERE (BatchPass=Variance_Pass and Scan_date=Variance_Scan_Date and Number_of_Counts=2) or (BatchPass=Variance_Pass and BatchPass > 2 and Number_of_Counts=1);
    
CONCATENATE (Cycle_Count_Final)
LOAD
	BatchNumber as Batch_Number,
    SKU,
    StoreNumber as Store_Number,
    OnHand as MMS_Qty,
    ScannedCnt as Count_Qty,
    BatchPass,
    StoreNumber as %storeKey,
    SKU as %itemKey,
    Date_Key,
    Initial_Date as Scan_Date,
    Initial_Scan_Date as Scan_Tmstmp,
    'Initial Count' as Count_Type
    RESIDENT Cycle_Count
    WHERE (BatchPass=Initial_Pass and Scan_date=Initial_Scan_Date and Number_of_Counts=1 and BatchPass<3) ;
    
    DROP TABLE Cycle_Count;