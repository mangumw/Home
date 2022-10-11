 SELECT a.Pub_Code as Pub_Group,
    a.Purchases_TY, 
    a.Purchases_LY, 
    IIf(a.Purchases_LY = 0, 0, (a.Purchases_TY - a.Purchases_LY) / a.Purchases_LY) AS [Purchases % Inc/Dec], 
    a.Returns_TY, 
    a.Returns_LY, 
    IIf(a.Returns_LY = 0, 0, (a.Returns_TY - a.Returns_LY) / a.Returns_LY) AS [Returns % Inc/Dec], 
    IIf(a.Purchases_TY = 0, 0, a.Returns_TY / a.Purchases_TY) AS [Return %],
    a.Purchases_TY - a.Returns_TY AS NetTY, /*I*/
    a.Purchases_LY - a.Returns_LY AS NetLY, /*J*/
    --IIf([RefundsLY]=0,0,([RefundsTY]-[RefundsLY])/[RefundsLY]) AS K, 
    a.Sales_TY, 
    a.Sales_LY, 
    IIf(a.Sales_LY = 0, 0, (a.Sales_TY - a.Sales_LY) / a.Sales_LY) AS [Sales % Inc/Dec], 
    a.CoOp_TY, 
    a.CoOp_LY, 
    IIf(a.CoOp_LY = 0, 0, (a.CoOp_TY - a.CoOp_LY) / a.CoOp_LY) AS [CoOp % Inc/Dec], 
    a.Inv_TY, 
    a.Inv_LY ,
    IIf(a.Inv_LY = 0, 0, (a.Inv_TY - a.Inv_LY) / a.Inv_LY) AS [Inv % Inc/Dec], 
    a.Date_Loaded
FROM dssdata.dbo.Publisher_Scorecard_YTD_PubGrp a
WHERE 
    (   
        a.Purchases_TY > 0 OR 
        a.Purchases_LY > 0 OR 
        a.Returns_TY   > 0 OR 
        a.Returns_LY > 0
    )