USE [Markdowns]
GO
/****** Object:  Table [dbo].[MarkdownDelete]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MarkdownDelete](
	[MarkdownID] [int] NOT NULL,
	[BatchNo] [int] NOT NULL,
	[Category] [varchar](10) NOT NULL,
	[Dept] [smallint] NOT NULL,
	[ItemKey] [varchar](20) NULL,
	[Title] [varchar](35) NOT NULL,
	[OldPrice] [money] NOT NULL,
	[NewPrice] [money] NOT NULL,
	[Qty] [smallint] NOT NULL,
	[ReasonID] [tinyint] NOT NULL,
	[DateAdd] [datetime] NOT NULL,
	[StoreNo] [smallint] NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[Validated] [tinyint] NOT NULL,
	[ApprovalUser] [varchar](20) NOT NULL,
	[Posted] [tinyint] NOT NULL,
	[LinePos] [tinyint] NOT NULL,
	[DateLastMod] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[InvenPhysAdj] [datetime] NULL,
	[OrigOldPrice] [money] NULL,
	[Event] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
