USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_discount_activity_kpi]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_build_discount_activity_kpi] as 

declare @TYday smalldatetime
select @TYday = Dateadd(dd,-1,staging.dbo.fn_DateOnly(Getdate()))

-- daily feed of discount card activity for use in kpi files - 
-- created by Larry Eady 01/30/2011 --- 


insert into  staging..discount_activity_kpi

SELECT   day_date,Store_Number,Transaction_Code,  SUM(Extended_Price) AS [Total Sales]
FROM         DssData.dbo.Other_Transaction_History

WHERE     day_date =@tyday-6
and transaction_code ='mc'
GROUP BY day_date,Store_Number,  Transaction_Code



insert into  staging..discount_activity_kpi
SELECT     day_date,Store_Number,Transaction_Code,  SUM(Extended_Price) AS [Total Sales]

FROM         DssData.dbo.Detail_Transaction_History
WHERE    day_date =@tyday-6
and transaction_code ='mc'
GROUP BY day_date,Store_Number,  Transaction_Code
GO
