SELECT a.Pub_Code as Pub_Group,
    IIf(a.Purchases_LY = 0, 0, (a.Purchases_TY - a.Purchases_LY) / a.Purchases_LY) AS [Purchases % Inc/Dec], 
	case when 
		a.Purchases_TY = 0
		THEN 0
		ELSE a.Purchases_TY - a.Purchases_LY / a.Purchases_LY 
		END AS FUCKIT,
    IIf(a.Returns_LY = 0, 0, (a.Returns_TY - a.Returns_LY) / a.Returns_LY) AS [Returns % Inc/Dec], 
    IIf(a.Purchases_TY = 0, 0, a.Returns_TY / a.Purchases_TY) AS [Return %],
    IIf(a.Sales_LY = 0, 0, (a.Sales_TY - a.Sales_LY) / a.Sales_LY) AS [Sales % Inc/Dec], 
    IIf(a.CoOp_LY = 0, 0, (a.CoOp_TY - a.CoOp_LY) / a.CoOp_LY) AS [CoOp % Inc/Dec], 
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
	AND a.PUB_CODE like 'SCHOL%'