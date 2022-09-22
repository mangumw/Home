use staging
go

exec sp_rename
'tmp_CARD_new.SKU_Number',
'SKU',
'Column'
GO
