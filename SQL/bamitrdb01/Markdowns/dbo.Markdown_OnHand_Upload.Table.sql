USE [Markdowns]
GO
/****** Object:  Table [dbo].[Markdown_OnHand_Upload]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Markdown_OnHand_Upload](
	[OnHand_ID] [int] IDENTITY(0,1) NOT NULL,
	[IMPLOC] [int] NOT NULL,
	[IMPITM] [varchar](17) NOT NULL,
	[IMPDAT] [varchar](8) NOT NULL,
	[IMPQTY] [int] NOT NULL,
	[IMPREA] [varchar](25) NOT NULL,
	[IMPREF] [varchar](12) NOT NULL,
	[IMPLIN] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
