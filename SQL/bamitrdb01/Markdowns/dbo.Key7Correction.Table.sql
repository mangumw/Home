USE [Markdowns]
GO
/****** Object:  Table [dbo].[Key7Correction]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Key7Correction](
	[MarkdownID] [int] NOT NULL,
	[BatchNo] [int] NOT NULL,
	[Category] [varchar](10) NOT NULL,
	[Dept] [smallint] NOT NULL,
	[ItemKey] [varchar](20) NULL,
	[Title] [varchar](35) NOT NULL,
	[OldPrice] [smallmoney] NOT NULL,
	[NewPrice] [smallmoney] NOT NULL,
	[Qty] [smallint] NOT NULL,
	[ReasonID] [tinyint] NOT NULL,
	[DateAdd] [datetime] NOT NULL,
	[StoreNo] [smallint] NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[Validated] [tinyint] NOT NULL,
	[ApprovalUser] [varchar](20) NOT NULL,
	[Posted] [tinyint] NOT NULL,
	[LinePos] [tinyint] NOT NULL,
	[DateLastMod] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
