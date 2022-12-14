USE [BasilData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Populate_Basil_Data]    Script Date: 8/19/2022 4:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[usp_Populate_Basil_Data]
as

drop table [basildata]..[inventory];
drop table [BasilData].[dbo].[book_sections];
drop table [BasilData].[dbo].[misc_item_sections];

CREATE TABLE [dbo].[inventory](
	[id] [int] NOT NULL,
	[store_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[unique_id] [nvarchar](30) NULL,
	[inventory_type_id] [int] NOT NULL,
	[location_id] [int] NOT NULL,
	[barcode_id] [nvarchar](30) NOT NULL,
	[condition_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[storeprice] [decimal](10, 2) NOT NULL,
	[credit] [decimal](10, 2) NOT NULL,
	[cashvalue] [decimal](10, 2) NOT NULL,
	[cost] [decimal](10, 2) NOT NULL,
	[on_hand] [int] NOT NULL,
	[vendor_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[sku_id] [nvarchar](50) NOT NULL,
	[status] [nvarchar](25) NOT NULL,
	[created] [datetime] NOT NULL,
	[modified] [datetime] NOT NULL
) ON [PRIMARY];


CREATE TABLE [dbo].[book_sections](
	[id] [int] NOT NULL,
	[store_id] [int] NULL,
	[value] [nvarchar](100) NULL,
	[internal_code] [nvarchar](100) NULL,
	[edelweiss_code] [nvarchar](100) NULL,
	[department_code] [nvarchar](50) NULL,
	[is_removed] [int] NULL,
	[last_updated] [datetime] NULL,
	[store6_id] [int] NULL
) ON [PRIMARY];


CREATE TABLE [dbo].[misc_item_sections](
	[id] [int] NOT NULL,
	[store_id] [int] NULL,
	[value] [nvarchar](100) NULL,
	[internal_code] [nvarchar](100) NULL,
	[edelweiss_code] [nvarchar](100) NULL,
	[department_code] [nvarchar](50) NULL,
	[is_removed] [int] NULL
) ON [PRIMARY];

INSERT INTO [BasilData].[dbo].[inventory]
           ([id]
           ,[store_id]
           ,[user_id]
           ,[unique_id]
           ,[inventory_type_id]
           ,[location_id]
           ,[barcode_id]
           ,[condition_id]
           ,[section_id]
           ,[storeprice]
           ,[credit]
           ,[cashvalue]
           ,[cost]
           ,[on_hand]
			,[vendor_id]
		   ,[customer_id]
           ,[sku_id]
           ,[status]
           ,[created]
           ,[modified])
SELECT * 
FROM openquery(BASIL_PROD,'select id
         ,store_id
           ,user_id
           ,unique_id
           ,inventory_type_id
           ,location_id
           ,barcode_id
           ,condition_id
           ,section_id
           ,storeprice
           ,credit
           ,cashvalue
           ,cost
           ,on_hand
			,vendor_id
           ,customer_id
           ,sku_id
           ,status 
		,created
           ,modified from basil_prod.inventory');

INSERT INTO [BasilData].[dbo].[book_sections]
           ([id]
           ,[store_id]
           ,[value]
           ,[internal_code]
           ,[edelweiss_code]
           ,[department_code]
           ,[is_removed]
           ,[last_updated]
           ,[store6_id])
SELECT * 
FROM openquery(BASIL_PROD,'select id
            id
           ,store_id
           ,value
           ,internal_code
           ,edelweiss_code
           ,department_code
           ,is_removed
           ,last_updated
           ,store6_id from basil_prod.book_sections');

INSERT INTO [BasilData].[dbo].[misc_item_sections]
           ([id]
           ,[store_id]
           ,[value]
           ,[internal_code]
           ,[edelweiss_code]
           ,[department_code]
           ,[is_removed])
SELECT * 
FROM openquery(BASIL_PROD,'select id
            id
           ,store_id
           ,value
           ,internal_code
           ,edelweiss_code
           ,department_code
           ,is_removed from basil_prod.misc_item_sections');