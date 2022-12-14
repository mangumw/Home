/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
      a.StoreNumber
	  ,a.[BatchNumber]
	  , a.SKU
	  , SUM(a.OnHand) ONHAND
	  , SUM(b.ScannedCnt) ScannedCnt
	  , SUM(a.OnHand)  - SUM(b.ScannedCnt) as Diff
	  , a.BatchPass
	  , c.BatchPassDecr
	  , b.DateCreated
  FROM [SCC].[dbo].[tblBatchDetails] a
  INNER JOIN [dbo].[tblScannedItems] b
	ON a.BatchNumber = b.BatchNumber
		AND a.SKU = b.SKU
		AND  a.StoreNumber = b.StoreNumber
		AND a.BatchPass = b.BatchPass
	INNER JOIN [dbo].[tblBatchPassValues] c
		ON a.BatchPass = c.BatchPass
  GROUP BY a.BatchNumber,
			a.SKU,
			a.StoreNumber,
			b.ScannedCnt,
			b.DateCreated,
			a.BatchPass,
			c.BatchPassDecr
  order by 1, 2 desc