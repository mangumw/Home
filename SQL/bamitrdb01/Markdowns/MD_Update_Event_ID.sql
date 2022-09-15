  update Markdowns.dbo.Markdowns
  set Markdowns.dbo.Markdowns.Event = a.event_id
  from [StoreCountMarkdowns].[dbo].[MD_Event_Sku] a
  WHERE Markdowns.dbo.Markdowns.ItemKey = convert(varchar(200),a.sku)