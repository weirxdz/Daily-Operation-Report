/****** Object:  Table [dbo].[fr_calendar]    Script Date: 2023-10-08 12:53:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[fr_calendar](
	[dDate] [date] NOT NULL,
	[fr_day] [varchar](10) NOT NULL,
	[fr_Month] [int] NOT NULL,
	[fr_Year] [int] NOT NULL,
	[fr_day_0] [varchar](10) NOT NULL,
	[fr_Month_0] [int] NOT NULL,
	[fr_Year_0] [int] NOT NULL,
 CONSTRAINT [PK_fr_calendar] PRIMARY KEY CLUSTERED 
(
	[dDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'dDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'字符串化的单据日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_day'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'月份' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_Month'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'年度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_Year'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'字符串化的去年日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_day_0'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'去年月份' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_Month_0'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'去年年度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'fr_calendar', @level2type=N'COLUMN',@level2name=N'fr_Year_0'
GO
