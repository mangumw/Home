SELECT * FROM EDW.STG.PIE022(NOLOCK)
WHERE CAST(DatePosted AS DATE) > CAST(DATEADD(YEAR, -3, GETDATE()) AS DATE)

SELECT DATEADD(YEAR, -3, GETDATE()), CAST( DATEADD(YEAR, -3, GETDATE()) AS DATE)

declare @start datetime = cast(getdate() - 1 as date)
declare @end datetime = cast(getdate() - 1095 as date)
set @end = dateadd(second, 86399, @end)


SELECT * FROM EDW.STG.PIE022(NOLOCK)
WHERE @Start > @end