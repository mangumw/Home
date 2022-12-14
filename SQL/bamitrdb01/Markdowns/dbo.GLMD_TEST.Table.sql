USE [Markdowns]
GO
/****** Object:  Table [dbo].[GLMD_TEST]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GLMD_TEST](
	[MCONTL] [char](9) NOT NULL,
	[MYY] [decimal](2, 0) NOT NULL,
	[MMM] [decimal](2, 0) NOT NULL,
	[MDD] [decimal](2, 0) NOT NULL,
	[MSTORE] [char](4) NOT NULL,
	[MDEPT] [char](2) NOT NULL,
	[MTYPE] [char](2) NOT NULL,
	[MAMT] [decimal](9, 2) NOT NULL,
	[MBATCH] [char](4) NOT NULL,
	[MFLAG] [char](1) NOT NULL,
	[MMMCL] [decimal](2, 0) NOT NULL,
	[MYYCL] [decimal](2, 0) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
