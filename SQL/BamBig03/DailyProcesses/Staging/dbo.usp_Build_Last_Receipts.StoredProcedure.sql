USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Last_Receipts]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Build_Last_Receipts]
as
truncate table reference.dbo.LastReceipts
--
insert into Reference.dbo.LastReceipts
SELECT            staging.dbo.fn_IntToDate(MAX(RCRCDT)) AS LastDate, 

                        RCRCDT as LastDateInt,

                        RCITNO as ISBN, 

                        RCORQT as Order_Qty, 

                        Staging.dbo.fn_IntToDate(RCDUDT) as DueDate, 

                        RCPONO as PO_Number, 

                        RCVNNO as Vendor_Number, 

                        RCWHID as Warehouse, 

                        RCRCQT as Receipt_Qty

FROM Reference.dbo.RCPT

GROUP BY LEN(RCRCDT), RCITNO, RCORQT, RCDUDT, RCPONO, RCVNNO, RCWHID, RCRCQT,RCRCDT

HAVING (LEN(RCRCDT) = 5) AND (RCWHID = '1')


GO
