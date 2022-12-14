USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Emp_Status_Change_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Emp_Status_Change_Report]
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
declare @position varchar(9)
declare @Company_Number int
declare @Region_Number int
declare @District_Number int
declare @Store_Number varchar(4)
declare @Date_Stamp smalldatetime
declare @Beg_Date smalldatetime
declare @Emp_Status varchar(2)
declare @Cafe_Flag char(1)
declare @AValue varchar(50)
declare @NValue float
declare @DValue varchar(20)
--
declare @Last_Employee decimal(18,0)
--
-- Load Temp Table

select	fld_nbr,
		case t2.FLD_NBR
--			when 2				-- Last Name Change
--				then 'L'		
			when 24				-- Hire Date Change
				then 'A'
			when 27 			-- Term Date Change
				then 'C'
--			when 19				-- Job Code Change
--				then 'B'
--			when 15				-- Department Change
--				then 'D'
--			when 17				-- Location Change
--				then 'E'
			when 20				-- Emp Status
				then 'F'
--			when 50				-- SSN change
--				then 'S'
--			when 62				-- Pay Rate
--				then 'G'
--			when 126			-- Position
--				then 'H'
		end as EAction,


		t2.Date_Stamp,
		t2.Beg_Date,
		t1.FICA_Nbr as SSN,
		t1.Last_Name as Last_Name,
		t1.First_Name as First_Name,
		t1.Middle_Init as Initial,
		t1.Employee as Employee,
		t1.Adj_Hire_Date as Hire_Date,
		t1.Job_Code as Job_Code,
		t1.position as Position,
		t1.Company as Company_Number, ---  04/05  Larry Eady added case statement to include 2nC and YoMo org 
		t3.region_number as Region_Number,
		t3.district_number as District_Number,
		t1.Department as Store_Number,
		t1.Emp_Status as Emp_Status,
		isnull(t3.Cafe_Flag,'Y') as Cafe_Flag,
		t2.A_Value,
		t2.D_Value,
		t2.N_Value
into	
#Emp

from	reference.dbo.DBHREMP t1 left join staging.dbo.tmp_DBHRHRH t2
		on t2.employee = t1.employee left join reference.dbo.LMS_Stores t3
		on t3.store_number = t1.department 
where isnumeric(t1.department) = 1 
--commented out to include stores 2100 and 2101-- Larry Eady 02/10/11
--t2.FLD_NBR in (24,27,20) --(19,24,27,15,17,20,62,126)
--and 
 and 
t1.company<400
order by t1.employee,t2.fld_nbr
--
-- get distinct employees 
--
truncate table Reference.dbo.Employee_Changes
--
select @Last_Employee = '00000'
--
declare cur cursor for select EAction,Date_Stamp,Beg_Date,SSN,Last_Name,First_Name,Initial,Employee,Hire_Date,Job_Code,Position,Region_Number,District_Number,Store_Number,Emp_Status,Cafe_Flag,Company_Number,A_Value,D_Value,N_Value
						from #Emp where isnumeric(store_number) = 1 order by Employee,EAction
open cur
fetch next from cur into @Action,@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Employee,@Hire_Date,@Job_Code,@position, @Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag,@AValue,@DValue,@NValue
while @@Fetch_Status = 0
begin
if @Action = 'A'
begin
  if NOT exists (select employee from Reference.dbo.Employee_Changes where employee = @employee)
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'A',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
if @Action = 'B' 
begin
  if NOT exists (select employee from Reference.dbo.Employee_Changes where employee = @employee)
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Job Code Change',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@AValue,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
if @Action = 'C' 
begin
  if @DValue <> '0001-01-01'
	begin
    if NOT exists (select employee from Reference.dbo.Employee_Changes where employee = @employee)
      insert into Reference.dbo.Employee_Changes
      values(@Employee,'U',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
    end
  end
if @Action = 'D' 
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Department Change',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@AValue,@Emp_Status,@Cafe_Flag)
end
if @Action = 'E' 
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Location Change',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@AValue,@Emp_Status,@Cafe_Flag)
end
if @Action = 'F' 
  if left(@AValue,1) = 'A' and abs(datediff(dd,@hire_date,@beg_date)) < 5
	begin
    if NOT exists (select employee from Reference.dbo.Employee_Changes where employee = @employee)
      insert into Reference.dbo.Employee_Changes
      values(@Employee,'A',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
    end
if @Action = 'G' 
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Pay Change',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
if @Action = 'H' 
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Position Change',@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
--
if @Action = 'L'
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Lastname Change',@Date_Stamp,@Beg_Date,@SSN,@AValue,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
--
if @Action = 'S' 
begin
  insert into Reference.dbo.Employee_Changes
  values(@Employee,'Lastname Change',@Date_Stamp,@Beg_Date,@AValue,@AValue,@First_Name,@Initial,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag)
end
--
select @Last_Employee = @Employee
--
fetch next from cur into @Action,@Date_Stamp,@Beg_Date,@SSN,@Last_Name,@First_Name,@Initial,@Employee,@Hire_Date,@Job_Code,@position,@Company_Number,@Region_Number,@District_Number,@Store_Number,@Emp_Status,@Cafe_Flag,@AValue,@DValue,@NValue
End
close cur
deallocate cur


update reference..employee_changes
set company =
case when cast(store_number as int) between 2000 and 2999 then '2C' 
when cast(store_number as int) >3000 then 'YOMO' else '300' end  
from 
reference..employee_changes
GO
