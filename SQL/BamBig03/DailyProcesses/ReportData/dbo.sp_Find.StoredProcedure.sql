USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[sp_Find]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[sp_Find] 
	  @SearchText varchar(8000)
	, @DBName sysname = Null
	, @PreviewTextSize int = 100
	, @SearchDBsFlag char(1) = 'Y'
	, @SearchJobsFlag char(1) = 'Y'
	, @SearchSSISFlag char(1) = 'Y'
As
/*
* Created: 12/19/06, Michael F. Berry (SQL Server Magazine contributor)
*
* Modified: 01/25/07, Michael F. Berry, Make it output to one main recordset for clarity
* Modified: 09/04/08, Bill Lescher and Chase Jones, Updated for SQL2005 and added Jobs & SSIS Packages
* Modified: 07/22/09, Bill L, Returning the PreviewText
*
* Description: Find any string within the T-SQL code on this SQL Server instance, specifically
*				Database objects and/or SQL Agent Jobs and/or SSIS Packages
*
* Test: sp_Find 'track'
*		sp_Find 'AS400'
*		sp_Find 'track', 'Common', 50
*		sp_Find 'track', 'Common', 50, 'Y', 'N', 'N' --DB Only
*		sp_Find 'track', 'Common', 50, 'N', 'N', 'Y' --SSIS Only
*/
Set Transaction Isolation Level Read Uncommitted;
Set Nocount On;

Create Table #FoundObject (
	  DatabaseName sysname
	, ObjectName sysname
	, ObjectTypeDesc nvarchar(60)
	, PreviewText varchar(max))--To show a little bit of the code

Declare	@SQL as nvarchar(max);

Select 'Searching For: ''' + @SearchText + '''' As CurrentSearch;

/**************************
*  Database Search
***************************/
If @SearchDBsFlag = 'Y'
Begin
	If @DBName Is Null --Loop through all normal user databases
	Begin
		Declare ObjCursor Cursor Local Fast_Forward For 
			Select	[Name]
			From	Master.sys.Databases
			Where	[Name] Not In ('AdventureWorks', 'AdventureWorksDW', 'Distribution', 'Master', 'MSDB', 'Model', 'TempDB');

		Open ObjCursor;

		Fetch Next From ObjCursor Into @DBName;
		While @@Fetch_Status = 0
		Begin
			Select @SQL = '
				Use [' + @DBName + ']

				Insert Into #FoundObject (
					  DatabaseName
					, ObjectName
					, ObjectTypeDesc
					, PreviewText)
				Select	Distinct
						  ''' + @DBName + '''
						, sch.[Name] + ''.'' + obj.[Name] as ObjectName
						, obj.Type_Desc
						, Replace(Replace(SubString(mod.Definition, CharIndex(''' + @SearchText + ''', mod.Definition) - ' + Cast(@PreviewTextSize / 2 As varchar) + ', ' + 
							Cast(@PreviewTextSize As varchar) + '), char(13) + char(10), ''''), ''' + @SearchText + ''', ''***' + @SearchText + '***'')
				From 	sys.objects obj 
				Inner Join sys.SQL_Modules mod On obj.Object_Id = mod.Object_Id
				Inner Join sys.Schemas sch On obj.Schema_Id = sch.Schema_Id
				Where	mod.Definition Like ''%' + @SearchText + '%'' 
				Order By ObjectName';

			Exec dbo.sp_executesql @SQL;

			Fetch Next From ObjCursor Into @DBName;
		End;

		Close ObjCursor;

		Deallocate ObjCursor;
	End
	Else --Only look through given database
	Begin
			Select @SQL = '
				Use [' + @DBName + ']

				Insert Into #FoundObject (
					  DatabaseName
					, ObjectName
					, ObjectTypeDesc
					, PreviewText)
				Select	Distinct
						  ''' + @DBName + '''
						, sch.[Name] + ''.'' + obj.[Name] as ObjectName
						, obj.Type_Desc
						, Replace(Replace(SubString(mod.Definition, CharIndex(''' + @SearchText + ''', mod.Definition) - ' + Cast(@PreviewTextSize / 2 As varchar) + ', ' + 
							Cast(@PreviewTextSize As varchar) + '), char(13) + char(10), ''''), ''' + @SearchText + ''', ''***' + @SearchText + '***'')
				From 	sys.objects obj 
				Inner Join sys.SQL_Modules mod On obj.Object_Id = mod.Object_Id
				Inner Join sys.Schemas sch On obj.Schema_Id = sch.Schema_Id
				Where	mod.Definition Like ''%' + @SearchText + '%'' 
				Order By ObjectName';

			Exec dbo.sp_ExecuteSQL @SQL;
	End;

	Select 'Database Objects' As SearchType;

	Select
		  DatabaseName
		, ObjectName
		, ObjectTypeDesc As ObjectType
		, PreviewText
	From	#FoundObject
	Order By DatabaseName, ObjectName;
End

/**************************
*  Job Search
***************************/
If @SearchJobsFlag = 'Y'
Begin
	Select 'Job Steps' As SearchType;


	Select	  j.[Name] As [Job Name]
			, s.Step_Id As [Step #]
			, Replace(Replace(SubString(s.Command, CharIndex(@SearchText, s.Command) - @PreviewTextSize / 2, @PreviewTextSize), char(13) + char(10), ''), @SearchText, '***' + @SearchText + '***') As Command
	From	MSDB.dbo.sysJobs j
	Inner Join MSDB.dbo.sysJobSteps s On j.Job_Id = s.Job_Id 
	Where	s.Command Like '%' + @SearchText + '%';
End

/**************************
*  SSIS Search
***************************/
If @SearchSSISFlag = 'Y'
Begin
	Select 'SSIS Packages' As SearchType;

	Select	  [Name] As [SSIS Name]
			, Replace(Replace(SubString(Cast(Cast(PackageData As varbinary(Max)) As varchar(Max)), CharIndex(@SearchText, Cast(Cast(PackageData As varbinary(Max)) As varchar(Max))) -
				@PreviewTextSize / 2, @PreviewTextSize), char(13) + char(10), ''), @SearchText, '***' + @SearchText + '***') As [SSIS XML]
	From	MSDB.dbo.sysDTSPackages90
	Where	Cast(Cast(PackageData As varbinary(Max)) As varchar(Max)) Like '%' + @SearchText + '%';
End
GO
