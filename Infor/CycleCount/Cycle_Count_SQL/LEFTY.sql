USE SCC
GO
SELECT BatchNumber
	, SKU
	, StoreNumber
	, MIN(BatchPass) as Initial_Pass
	, MAX(BatchPass) as Variance_Pass
	, CAST(MIN(Scan_date) as DATETIME) as Initial_Scan_Date
	, CAST(MAX(Scan_date) as DATE) as Variance_Scan_Date
	, CAST(MIN(Date_Key) as DATE) as Initial_Date
	, CAST(MAX(Date_Key) as DATE) as Variance_Date
	, COUNT(DISTINCT BatchPass) as Number_of_Counts
FROM Cycle_Count_Midway
GROUP BY BatchNumber,SKU,StoreNumber



