select * from source_detail
WHERE YEAR(stamp) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 YEAR))

select * from invoice_detail
WHERE YEAR(last_price_edited) = YEAR(CURDATE())