USE [Markdowns]
GO
/****** Object:  Table [dbo].[MarkdownUpload]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MarkdownUpload](
	[BatchNo] [int] NOT NULL,
	[YearAdded] [tinyint] NOT NULL,
	[MonthAdded] [tinyint] NOT NULL,
	[DayAdded] [tinyint] NOT NULL,
	[StoreNo] [smallint] NOT NULL,
	[Dept] [smallint] NOT NULL,
	[MD_Code] [char](2) NOT NULL,
	[TotalAmt] [decimal](9, 2) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
