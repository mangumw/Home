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
WHERE BatchPass=Initial_Pass 
		and Scan_date=Initial_Scan_Date  
		and Number_of_Counts=1 
		and BatchPass < 3   
