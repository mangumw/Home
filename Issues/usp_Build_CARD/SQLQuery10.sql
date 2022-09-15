truncate table staging.dbo.wrk_card_WMBAL
insert into staging.dbo.wrk_card_WMBAL
SELECT        ISBN, ISNULL(SUM(OnHand), 0) AS OnHand
FROM            Reference.dbo.WMBAL
WHERE        (LEFT(Location, 1) IN ('7', '8', '9')) AND (Warehouse = '1')
GROUP BY ISBN