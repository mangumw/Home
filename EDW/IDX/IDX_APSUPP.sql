USE [EDW]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [ClusteredIndex-20220523-164833]    Script Date: 5/24/2022 8:50:00 AM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20220523-164833] ON [dbo].[APSUPP]
(
	[VendorNumber] ASC,
	[VendorName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


