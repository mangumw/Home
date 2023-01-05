CREATE VIEW Cycle_Count_Answer
AS
SELECT a.BatchNumber as Batch_Number
	, a.SKU
	, a.StoreNumber as Store_Number
	, a.OnHand as MMS_Qty
	, a.ScannedCnt as Count_Qty
	, a.BatchPass
	, a.StoreNumber as StoreKey
	, a.SKU as ItemKey
	, CAST(a.Date_Key as DATE) as Date_Key
	, b.Variance_Date as Scan_Date
	, b.Variance_Scan_Date as Scan_Tmstmp
	, 'Variance Count' as Count_Type
FROM Cycle_Count_Midway a
LEFT JOIN LEFTY b
ON a.SKU = b.SKU
AND a.StoreNumber = b.StoreNumber
WHERE
  (a.BatchPass=b.Variance_Pass 
 AND a.Scan_Date=b.Variance_Scan_Date
 AND b.Number_of_Counts=2) 
 OR (a.BatchPass=b.Variance_Pass 
 AND a.BatchPass > 2 and b.Number_of_Counts=1)

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
ON a.SKU  = b.SKU 
AND a.StoreNumber = b.StoreNumber
WHERE 
(BatchPass=Initial_Pass 
AND Scan_date=Initial_Scan_Date 
AND Number_of_Counts=1 and BatchPass<3) 

