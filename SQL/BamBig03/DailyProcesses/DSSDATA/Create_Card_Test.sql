USE [Staging]
GO

/****** Object:  Table [dbo].[CARD]    Script Date: 9/22/2022 11:02:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CARD_TEST](
	[Sr# Buyer] [nvarchar](255) NULL,
	[Buyer] [nvarchar](255) NULL,
	[num] [float] NULL,
	[Sku] [float] NULL,
	[ISBN] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[Author] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Coordinate Group] [nvarchar](255) NULL,
	[Action Alley Code] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Retail] [money] NULL,
	[IDate] [datetime] NULL,
	[Expected Date] [datetime] NULL,
	[Pub Code] [nvarchar](255) NULL,
	[Store Min] [nvarchar](255) NULL,
	[BAM OnHand] [float] NULL,
	[Whse OnHand] [float] NULL,
	[On Order] [float] NULL,
	[On Back order] [float] NULL,
	[In Transit] [float] NULL,
	[Total On Hand] [float] NULL,
	[WTD Units] [float] NULL,
	[WTD Dollars] [money] NULL,
	[Wk 1 Units] [float] NULL,
	[Wk 1 Dollars] [money] NULL,
	[Wk 2 Units] [float] NULL,
	[Wk 2 Dollars] [money] NULL,
	[Wk 3 Units] [float] NULL,
	[Wk 3 Dollars] [money] NULL,
	[Wk 13 Units] [float] NULL,
	[Wk 13 Dollars] [money] NULL,
	[LY YTD Units] [money] NULL,
	[LY YTD Dollars] [money] NULL,
	[YTD Units] [float] NULL,
	[YTD Dollars] [money] NULL,
	[F37] [nvarchar](255) NULL
) ON [PRIMARY]
GO


