select	t2.fiscal_year,
		t2.fiscal_period,
		t1.Vendor,
		NULL,
		sum(t2.purchases_ty) as Purchases_TY,
		sum(t2.Purchases_LY) as Purchases_LY,
		sum(t2.Returns_ty) as Returns_TY,
		sum(t2.Returns_LY) as Returns_LY,
		sum(t2.Sales_ty) as Sales_TY,
		sum(t2.Sales_LY) as Sales_LY,
		sum(t2.CoOp_ty ) as CoOp_TY,
		sum(t2.CoOp_LY ) as CoOp_LY,
		sum(t2.Inv_ty) as Inv_TY,
		sum(t2.Inv_LY) as Inv_LY,
		getdate()
from	reference.dbo.Scorecard_Pubs_Groups2 t1,
		dssdata.dbo.Publisher_Scorecard_YTD t2
where	t2.pub_Code=t1.pub
group by t2.fiscal_year,t2.fiscal_period,t1.vendor
order by t1.vendor