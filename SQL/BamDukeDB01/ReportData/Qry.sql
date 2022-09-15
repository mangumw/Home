DECLARE @Start as DATETIME
DECLARE @End as DATETIME

SET @Start = ISNULL(@Start,'2022-03-01')
SET @End = ISNULL(@End, '2022-03-31')


select *
FROM [dbo].[FUQQ] a
WHERE 
	convert(DATE, a.Date_Key, 101) >= @Start 
AND convert(DATE, a.Date_Key, 101) <= @End
ORDER BY a.Date_Key DESC