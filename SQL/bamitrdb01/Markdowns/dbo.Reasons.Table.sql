USE [Markdowns]
GO
/****** Object:  Table [dbo].[Reasons]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reasons](
	[ReasonID] [tinyint] NOT NULL,
	[ReasonDesc] [varchar](25) NOT NULL,
	[ReasonStatus] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Reasons] ADD  DEFAULT ((0)) FOR [ReasonStatus]
GO
