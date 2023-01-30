CREATE TABLE [dim].[Calendar]
(
	[CalendarDate]					DATE			NOT NULL,
	CONSTRAINT	[PKNC_Calendar]		PRIMARY KEY NONCLUSTERED([CalendarDate]),
	INDEX		[CCSX_Calendar]		CLUSTERED COLUMNSTORE
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Calendar table of continugous dates.',
	@level0type	= N'schema',	@level0name	= N'dim',
	@level1type	= N'table',		@level1name	= N'Calendar';

/*

DECLARE	@DateBeg	DATE	= '1980-01-01';
DECLARE	@DateEnd	DATE	= '2025-12-31';

INSERT INTO [dbo].[Calendar1] WITH(TABLOCK)
(
	[Calendar1Date]
)
SELECT
	[t].[CalendarDate]
FROM
	[dbo].[Select_CalendarDates](@DateBeg, @DateEnd)	[t]
WHERE
	([t].[CalendarDate] NOT IN (SELECT [x].[Calendar1Date] FROM [dbo].[Calendar1] [x]));

*/