SELECT a.StoreNo 
	, a.MarkdownID
	, convert(varchar(200), a.ItemKey) as ItemKey
	, len(a.ItemKey) as ItemKeyLength
	, a.Qty
	, a.[DATEADD]
	, b.ReasonID
	, b.ReasonDesc
	, b.ReasonStatus
FROM [Markdowns].[dbo].[Markdowns] a
INNER JOIN [Markdowns].[dbo].[Reasons] b
	ON a.ReasonID = b.ReasonID
INNER JOIN [StoreCountMarkdowns].[dbo].[Event_Sku_Xref] c
	ON a.ItemKey = convert(varchar(200),c.sku)
ORDER BY a.[DateAdd] DESC