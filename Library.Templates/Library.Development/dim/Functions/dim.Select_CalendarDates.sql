CREATE FUNCTION [dim].[Select_CalendarDates]
(
	@DateBeg	DATE,
	@DateEnd	DATE
)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN
(
	WITH [ListDatesCte]
	(
		[CalendarDate]
	)
	AS
	(
		SELECT [CalendarDate]	= @DateBeg
		UNION ALL
		SELECT [CalendarDate]	= DATEADD(DAY, 1, [l].[CalendarDate])
		FROM
			[ListDatesCte] [l]
		WHERE
			([l].[CalendarDate]	< @DateEnd)
	)
	SELECT
		[t].[CalendarDate]
	FROM
		[ListDatesCte]	[t]
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Selects continuous dates from @DateBeg to @DateEnd, inclusive.',
	@level0type	= N'schema',	@level0name	= N'dim',
	@level1type	= N'function',	@level1name	= N'Select_CalendarDates';