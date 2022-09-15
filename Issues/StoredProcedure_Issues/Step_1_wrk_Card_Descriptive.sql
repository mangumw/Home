truncate table Staging.dbo.wrk_Card_Descriptive


insert into Staging.dbo.wrk_Card_Descriptive 
(      [ISBN]
      ,[Sku_Number]
      ,[EAN]
      ,[DW_ISBN]
      ,[Title]
      ,[Status]
      ,[Pub_Code]
      ,[Publisher]
      ,[VIN]
      ,[Author]
      ,[Returnable]
      ,[Disposition]
      ,[Sr_Buyer]
      ,[Buyer]
      ,[Buyer_Number]
      ,[Dept]
      ,[Dept_Name]
      ,[SDept]
      ,[SDept_Name]
      ,[Class]
      ,[Class_Name]
      ,[SClass]
      ,[SClass_Name]
      ,[Module]
      ,[Sku_Type]
      ,[Subject]
      ,[Strength]
      ,[Retail]
      ,[DWCost]
      ,[Min_Qty]
      ,[Max_Qty]
      ,[Coordinate_Group]
      ,[Season]
      ,[IDate]
      ,[ExpReceiptDate]
      ,[Condition]
      ,[Sku_Text]
)
SELECT     Reference.dbo.INVMST.ISBN, Reference.dbo.INVMST.Sku_Number, Reference.dbo.Item_Master.EAN, NULL AS DW_ISBN, Reference.dbo.INVMST.Description AS Title, 
                      Reference.dbo.INVMST.Status, Reference.dbo.INVMST.Pub_Code, Reference.dbo.Item_Master.Publisher, Reference.dbo.INVMST.Vendor_Number AS VIN, 
                      Reference.dbo.INVMST.Author, Reference.dbo.Item_Master.Returnable, Reference.dbo.Item_Master.Disposition, Reference.dbo.Buyer_SrBuyer_XRef.Sr_Buyer, 
                      Reference.dbo.Buyer_SrBuyer_XRef.Buyer, Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number, Reference.dbo.INVMST.Dept, 
                      Reference.dbo.Item_Master.Dept_Name, Reference.dbo.INVMST.SDept, Reference.dbo.Item_Master.SDept_Name, Reference.dbo.INVMST.Class, 
                      Reference.dbo.Item_Master.Class_Name, Reference.dbo.INVMST.SClass, Reference.dbo.Item_Master.SClass_Name, Reference.dbo.INVMST.Module, 
                      Reference.dbo.INVMST.Sku_Type, Reference.dbo.INVMST.Subject, Reference.dbo.INVMST.Strength, Reference.dbo.INVMST.POS_Price AS Retail, 
                      Reference.dbo.ITBAL.DWCost, Reference.dbo.ITBAL.Min_Qty, Reference.dbo.ITBAL.Max_Qty, Reference.dbo.INVMST.Coordinate_Group, 
                      Reference.dbo.INVMST.Season, Reference.dbo.INVMST.Date_First_Activity AS IDate, dbo.fn_IntToDate(Reference.dbo.INVMSTE.ExpReceiptDate) AS ExpReceiptDate, 
                      Reference.dbo.INVMST.Condition, Reference.dbo.Item_Master.Sku_Text
FROM         Reference.dbo.INVMST INNER JOIN
                      Reference.dbo.Item_Master ON Reference.dbo.Item_Master.SKU_Number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.Buyer_SrBuyer_XRef ON Reference.dbo.Buyer_SrBuyer_XRef.Buyer_Number = Reference.dbo.INVMST.Buyer_Number INNER JOIN
                      Reference.dbo.INVMSTE ON Reference.dbo.INVMSTE.Sku_Number = Reference.dbo.INVMST.Sku_Number LEFT OUTER JOIN
                      Reference.dbo.ITBAL ON Reference.dbo.ITBAL.Sku_Number = Reference.dbo.INVMST.Sku_Number
WHERE     (Reference.dbo.INVMST.Sku_Type <> 'M')