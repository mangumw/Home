USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_comm_ed_card]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_comm_ed_card] as 

truncate table staging.dbo.comm_ed_list
insert into staging.dbo.comm_ed_list

SELECT     MCustNum, MCustnumInt, MSpecial, PclientType
FROM         DssData.dbo.GCLU
WHERE     (MSpecial IN ('COMM', 'TEACHER', 'CORP')) OR
                      (PclientType = 'INS')

declare @BEG smalldatetime
select @BEG = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))

insert into staging.dbo.comm_ed_file1

SELECT     DssData.dbo.Detail_Transaction_History.Day_Date, DssData.dbo.Detail_Transaction_History.Store_Number, 
                      DssData.dbo.Tender_Transaction.Transaction_Number AS Expr1, SUM(DssData.dbo.Detail_Transaction_History.Extended_Price) AS Expr2, 
                      DssData.dbo.Detail_Transaction_History.Customer_Number
FROM         DssData.dbo.Tender_Transaction INNER JOIN
                      DssData.dbo.Detail_Transaction_History INNER JOIN
                      Staging.dbo.comm_ed_list ON DssData.dbo.Detail_Transaction_History.Customer_Number = Staging.dbo.comm_ed_list.MCustnumInt ON 
                      DssData.dbo.Tender_Transaction.day_date = DssData.dbo.Detail_Transaction_History.Day_Date AND 
                      DssData.dbo.Tender_Transaction.Store_Number = DssData.dbo.Detail_Transaction_History.Store_Number AND 
                      DssData.dbo.Tender_Transaction.Sequence_Number = DssData.dbo.Detail_Transaction_History.Sequence_Nbr AND 
                      DssData.dbo.Tender_Transaction.Register_Number = DssData.dbo.Detail_Transaction_History.Register_Nbr AND 
                      DssData.dbo.Tender_Transaction.Transaction_Number = DssData.dbo.Detail_Transaction_History.Transaction_Nbr
GROUP BY DssData.dbo.Detail_Transaction_History.Day_Date, DssData.dbo.Detail_Transaction_History.Store_Number, 
                      DssData.dbo.Detail_Transaction_History.Customer_Number, DssData.dbo.Tender_Transaction.Transaction_Number
HAVING      DssData.dbo.Detail_Transaction_History.Day_Date = @BEG


--declare @stores int
--truncate table staging.dbo.comm_ed_file2
--declare cur cursor for select store_number from reference.dbo.active_stores
--open cur
--fetch next from cur into @stores
--while @@fetch_status = 0
--begin 
--insert into staging.dbo.comm_ed_file2
--select top 30 * from staging.dbo.comm_ed_file1
--
--select * from staging.dbo.comm_ed_file1


--truncate table staging.dbo.comm_ed_file2
--insert into staging.dbo.comm_ed_file2
--
--SELECT top 250 Day_Date, Store_Number, COUNT(Expr1) AS transaction_ct, SUM(Expr2) AS dollars, Customer_Number
--FROM         Staging.dbo.comm_ed_file1
--GROUP BY Day_Date, Store_Number, Customer_Number
--HAVING      (Store_Number > 55)
--ORDER BY dollars DESC













GO
