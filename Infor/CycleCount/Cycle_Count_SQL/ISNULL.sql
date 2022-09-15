DECLARE @Start as DATETIME
DECLARE @End as DATETIME

SET @Start = ISNULL(@Start,'2022-03-01')
SET @End = ISNULL(@End, '2022-03-31')

SELECT *
FROM Cycle_Count_Answer
WHERE Date_Key >= @Start
AND Date_Key <= @End