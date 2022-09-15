USE [Markdowns]
GO
/****** Object:  Table [dbo].[Active_Stores]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Active_Stores](
	[Region_Number] [int] NULL,
	[Region_Name] [varchar](50) NULL,
	[district_number] [int] NULL,
	[District_Name] [varchar](50) NULL,
	[Store_Number] [int] NULL,
	[Store_Name] [varchar](50) NULL,
	[DM_EMail] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
