CREATE TABLE [$SchemaName$].[$rawname$]
(
	[$rawname$Date]					DATE			NOT NULL,
	CONSTRAINT	[PKNC_$rawname$]		PRIMARY KEY NONCLUSTERED([$rawname$Date]),
	INDEX		[CCSX_$rawname$]		CLUSTERED COLUMNSTORE
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Calendar table of continugous dates.',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'table',		@level1name	= N'$rawname$';

/*

DECLARE	@DateBeg	DATE	= '1980-01-01';
DECLARE	@DateEnd	DATE	= '2025-12-31';

INSERT INTO [$SchemaName$].[$rawname$] WITH(TABLOCK)
(
	[$rawname$Date]
)
SELECT
	[t].[CalendarDate]
FROM
	[$SchemaName$].[Select_CalendarDates](@DateBeg, @DateEnd)	[t]
WHERE
	([t].[CalendarDate] NOT IN (SELECT [x].[$rawname$Date] FROM [$SchemaName$].[$rawname$] [x]))
OPTION
	(MAXRECURSION 0);

*/