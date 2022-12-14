USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_SOX_Emp_Change_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_SOX_Emp_Change_Report]
as
declare @Action char(1)
declare @SSN varchar(12)
declare @Last_Name varchar(30)
declare @first_name varchar(30)
declare @initial varchar(2)
declare @location varchar(30)
declare @Employee decimal(18,0)
declare @Hire_Date varchar(25)
declare @Job_Code varchar(9)
declare @Company_Number int
declare @Region_Number int
declare @District_Number int
declare @Store_Number varchar(5)
declare @User_ID varchar(10)
declare @Date_Stamp datetime
--
declare @Last_Employee decimal(18,0)
--
select @Last_Employee = 0
--
-- Load Temp Table
--
select	case t2.FLD_NBR
			when 24				-- Hire Date Change
				then 'A'
			when 27				-- Term Date Change
				then 'C'
			when 19				-- Job Code Change
				then 'B'
			when 15				-- Department Change
				then 'D'
			when 17				-- Location Change
				then 'E'
		end as EAction,
		t1.FICA_Nbr as SSN,
		t1.Last_Name as Last_Name,
		t1.First_Name as First_Name,
		t1.Middle_Init as Initial,
		t1.Employee as Employee,
		t2.User_ID,
		t2.Date_Stamp,
		t1.Date_Hired as Hire_Date,
		0 as Region_Number,
		0 as District_Number,
		t1.Job_Code as Job_Code,
		t1.Company as Company_Number,
		t1.Department as Store_Number
into	#emp
from	staging.dbo.tmp_DBHREMP t1,
		staging.dbo.tmp_DBHRHRH t2
where	t2.employee = t1.employee
and		t1.Process_Level ='CORP'
and		t2.FLD_NBR in (19,24,27,15,17)
-- 
-- get distinct employees 
--
truncate table reportdata.dbo.rpt_SOX_Emp_Change
--
declare cur cursor for select EAction,SSN,Last_Name,First_Name,Initial,Employee,User_ID,Date_Stamp,Hire_Date,Job_Code,Company_Number,Region_Number,District_Number,Store_Number
						from #Emp order by Employee,EAction
open cur
fetch next from cur into @Action,@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number
while @@Fetch_Status = 0
begin
if @Action = 'A'
begin
  insert into reportdata.dbo.rpt_SOX_Emp_Change
  values('New Hire',@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number)
end
if @Action = 'B' and @Employee <> @Last_Employee
begin
  insert into reportdata.dbo.rpt_SOX_Emp_Change
  values('Job Code Change',@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number)
end
if @Action = 'C' and @Employee <> @Last_Employee
begin
  insert into reportdata.dbo.rpt_SOX_Emp_Change
  values('Termination',@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number)
end
if @Action = 'D' and @Employee <> @Last_Employee
begin
  insert into reportdata.dbo.rpt_SOX_Emp_Change
  values('Department Change',@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number)
end
if @Action = 'E' --and @Employee <> @Last_Employee
begin
  insert into reportdata.dbo.rpt_SOX_Emp_Change
  values('Location Change',@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number)
end
--
select @Last_Employee = @Employee
--
fetch next from cur into @Action,@SSN,@Last_Name,@First_Name,@Initial,@Employee,@User_ID,@Date_Stamp,@Hire_Date,@Job_Code,@Company_Number,@Region_Number,@District_Number,@Store_Number
End
close cur
deallocate cur
GO
