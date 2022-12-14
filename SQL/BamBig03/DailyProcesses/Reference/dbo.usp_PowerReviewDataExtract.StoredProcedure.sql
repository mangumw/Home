USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_PowerReviewDataExtract]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leisha Kennedy
-- Create date: 01/03/2021
-- Description:	Power Review Text File
-- =============================================
CREATE PROCEDURE [dbo].[usp_PowerReviewDataExtract]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
--truncate table reference.dbo.tblPowerReview

insert into tblPowerReview (
page_id,
order_id,
First_Name,
Last_Name,
email,
order_date
)


Select page_id, order_id,
LEFT(FirstName,CHARINDEX(' ',FirstName)) AS  First_Name,
LTRIM(RTRIM(SUBSTRING(LastName,CHARINDEX(' ',LastName),100))) AS Last_Name,
email, order_date
from openquery(books, 
'Select pid as page_id, o.sid as order_id, 
cc.nm as FirstName, cc.nm as Name, cc.nm as LastName, cc.email, o.time_ord as order_date
from books.orders o inner join
books.items i on i.sid = o.sid inner join
books.credit_card cc on o.sid = cc.sid and i.sid = cc.sid inner join
books.ship_address sa on o.sid = sa.sid and i.sid = sa.sid and sa.sid = cc.sid
where o.time_ord BETWEEN CURDATE() - INTERVAL 1 DAY
        AND CURDATE() - INTERVAL 1 SECOND;')

--210 interval for all items from 06/08/2021 to 01/03/2022
--between ''2021-05-10 00:00:00.0000000'' AND ''2022-01-08 11:59:59.0000000''
--and cc.nm <> '' '' ')

END
GO
