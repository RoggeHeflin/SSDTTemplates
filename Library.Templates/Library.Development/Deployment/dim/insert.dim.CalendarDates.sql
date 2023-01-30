DECLARE	@DateBeg	DATE	= '1980-01-01';
DECLARE	@DateEnd	DATE	= '2025-12-31';

INSERT INTO [dim].[Calendar] WITH(TABLOCK)
(
	[CalendarDate]
)
SELECT
	[t].*
FROM
	[dim].[Select_CalendarDates](@DateBeg, @DateEnd)	[t]
WHERE
	([t].[CalendarDate] NOT IN (SELECT [x].[CalendarDate] FROM [dim].[Calendar] [x]))
OPTION
	(MAXRECURSION 0);