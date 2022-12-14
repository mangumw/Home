USE [Markdowns]
GO
/****** Object:  Table [dbo].[Calendar_Dim]    Script Date: 08/23/2022 14:29:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Calendar_Dim](
	[day_date] [datetime] NULL,
	[day_name] [varchar](12) NULL,
	[month_name] [varchar](12) NULL,
	[day_of_week_number] [int] NULL,
	[day_of_month_number] [int] NULL,
	[day_of_year_number] [int] NULL,
	[calendar_week] [int] NULL,
	[calendar_year] [int] NULL,
	[day_of_period] [int] NULL,
	[day_of_fiscal_year] [int] NULL,
	[fiscal_year] [int] NULL,
	[fiscal_quarter] [varchar](7) NULL,
	[fiscal_period] [int] NULL,
	[fiscal_period_week] [int] NULL,
	[fiscal_year_week] [int] NULL,
	[weekend_flag] [varchar](1) NULL,
	[first_day_of_month_flag] [varchar](1) NULL,
	[last_day_of_month_flag] [varchar](1) NULL,
	[end_of_pay_period_flag] [varchar](1) NULL,
	[holiday_flag] [varchar](1) NULL,
	[holiday_name] [varchar](75) NULL,
	[major_event_flag] [varchar](1) NULL,
	[major_event_name] [varchar](75) NULL,
	[record_date] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
