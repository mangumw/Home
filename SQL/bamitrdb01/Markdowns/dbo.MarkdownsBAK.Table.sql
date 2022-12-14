USE [Markdowns]
GO
/****** Object:  Table [dbo].[MarkdownsBAK]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MarkdownsBAK](
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
	[LinePos] [int] NOT NULL,
	[DateLastMod] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[InvenPhysAdj] [datetime] NULL,
	[OrigOldPrice] [money] NULL,
	[Event] [int] NULL,
 CONSTRAINT [PK_MarkdownsBAK] PRIMARY KEY CLUSTERED 
(
	[MarkdownID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MarkdownsBAK] ADD  CONSTRAINT [DF_MarkdownsBAK_InvenPhysAdj]  DEFAULT (NULL) FOR [InvenPhysAdj]
GO
ALTER TABLE [dbo].[MarkdownsBAK] ADD  CONSTRAINT [DF_MarkdownBAKs_OrigOldPrice]  DEFAULT ((0)) FOR [OrigOldPrice]
GO
