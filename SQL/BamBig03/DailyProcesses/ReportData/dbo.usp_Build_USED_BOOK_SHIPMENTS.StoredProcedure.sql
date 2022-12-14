USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_USED_BOOK_SHIPMENTS]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set ANSI_NULLS ON
--set QUOTED_IDENTIFIER ON
--GO
--
---------------------------------------------------------------------------
---- Procedure: usp_Build_CARD
----
---- This proc will build the CARD (Consolidatede As400 Reporting Data) Table
---- from the Following tables:	INVMST
----								INVCBL
----								ITBAL	
----								Weekly_Sales
----
---- The CARD table is essentially the AS400 - 999 Report.
----
---------------------------------------------------------------------------------
----
CREATE procedure [dbo].[usp_Build_USED_BOOK_SHIPMENTS]
as

SELECT A.FROM_STORE,A.BOL_ID,A.TRANSFER_DATE,A.RECEIVED_DATE,
B.TRANSFER_DATE AS TOTE_TRANSFER_DATE,B.RECEIVED_DATE AS TOTE_RECEIVED_DATE 
FROM dbo.USED_BOOK_TRANSFERS_MASTER A, dbo.USED_BOOK_TRANSFERS_DETAIL B
WHERE A.BOL_ID = B.BOL_ID ORDER BY A.BOL_ID
GO
