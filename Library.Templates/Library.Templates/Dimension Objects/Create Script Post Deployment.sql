DROP TABLE IF EXISTS #$rawname$Stage;
GO

/*
the 
Verify Tag, Abbr, Name, Desc data types match [$SchemaName$].[$rawname$LookUp]
ParentTag and Tag data types must be the same.

Insert hierarchy data in to 
INSERT INTO #$rawname$Stage

*/

CREATE TABLE #$rawname$Stage
(
	[$rawname$Tag]					NVARCHAR(10)		NOT	NULL,	CONSTRAINT [CL_$rawname$Stage_Tag]				CHECK([$rawname$Tag] <> ''),
	[$rawname$Abbr]					NVARCHAR(20)		NOT	NULL,	CONSTRAINT [CL_$rawname$Stage_Abbr]				CHECK([$rawname$Abbr] <> ''),
	[$rawname$Name]					NVARCHAR(60)		NOT	NULL,	CONSTRAINT [CL_$rawname$Stage_Name]				CHECK([$rawname$Name] <> ''),
	[$rawname$Desc]					NVARCHAR(80)		NOT	NULL,	CONSTRAINT [CL_$rawname$Stage_Desc]				CHECK([$rawname$Desc] <> ''),

	[$rawname$ParentTag]				NVARCHAR(10)		NOT	NULL,	CONSTRAINT [CL_$rawname$Stage_$rawname$Parent]	CHECK([$rawname$ParentTag] <> ''),

	[Operator]						CHAR(1)				NOT	NULL	CONSTRAINT [DF_$rawname$Stage_Operator]			DEFAULT('+'),
																	CONSTRAINT [CR_$rawname$Stage_Operator]			CHECK([Operator] IN ('+', '-')),
	[SortKey]						INT					NOT	NULL	CONSTRAINT [DF_$rawname$Stage_SortKey]			DEFAULT(1),

	CONSTRAINT [UX_$rawname$Stage_Tag]		PRIMARY KEY CLUSTERED ([$rawname$Tag]	ASC),
	CONSTRAINT [UX_$rawname$Stage_Abbr]		UNIQUE NONCLUSTERED ([$rawname$Abbr]	ASC),
	CONSTRAINT [UX_$rawname$Stage_Name]		UNIQUE NONCLUSTERED ([$rawname$Name]	ASC),
	CONSTRAINT [UX_$rawname$Stage_Desc]		UNIQUE NONCLUSTERED ([$rawname$Desc]	ASC)
);
GO

INSERT INTO #$rawname$Stage WITH(TABLOCK)
(
	[$rawname$Tag],
	[$rawname$Abbr],
	[$rawname$Name],
	[$rawname$Desc],
	[$rawname$ParentTag],
	[Operator],
	[SortKey]
)
SELECT
	[c].[$rawname$Tag],
	[c].[$rawname$Abbr],
	[c].[$rawname$Name],
	[c].[$rawname$Desc],
	[c].[$rawname$ParentTag],
	[c].[Operator],
	[c].[SortKey]
FROM (VALUES
	('Inc',			'Inc',			'Income',			'Income',				'Inc',	'+', 10000),
	
	('Rev',			'Rev',			'Revenue',			'Revenue',				'Inc',	'+', 40000),
		
		('State',		'State',		'State',		'State',				'Rev',	'+', 40200),
		('Comm',		'Comm',		'Commercial',	'Commercial',			'Rev',	'+', 40400),
		('Federal',		'Federal',		'Federal',		'Federal',				'Rev',	'+', 40600),

	('Exp',			'Exp',			'Expense',			'Expense',				'Inc',	'-', 70000),

	('Svcs',		'Svcs',		'Services',			'Services',				'Exp',	'-', 70100),
		('Comp',		'Comp',		'Compensation',		'Compensation',			'Svcs',	'-', 70100),
			('W',			'W',			'Wages',			'Wages',				'Comp',	'-', 70120),
			('B',			'B',			'Benefits',			'Benefits',				'Comp',	'-', 70140),

		('Data',		'Data',		'Data Processing',	'Data Processing',		'Exp',	'-', 70200),
		('Occ',			'Occ',			'Occupancy',		'Occupancy',			'Exp',	'-', 70300),
		('Prj',			'Prj',			'Project Costs',	'Project Costs',		'Exp',	'-', 70400),
		('Oth',			'Oth',			'Other Operating',	'Other Operating',		'Exp',	'-', 70500),

	('DITA',		'DITA',		'DITA',					'DITA',					'Exp',	'-', 71000),
		('Amor',		'Amor',		'Amortization',			'Amortization',			'DITA',	'-', 70600),

		('SGA',			'SGA',			'SG&A',					'SG&A',					'DITA',	'-', 70700),

		('IntExp',		'IntExp',		'Interest (Expense)',	'Interest (Expense)',	'DITA',	'-', 73000),
		('IntInc',		'IntInc',		'Interest (Income)',	'Interest (Income)',	'DITA',	'-', 74000),
		('Taxes',		'Taxes',		'Taxes',				'Taxes',				'DITA',	'-', 75000)

	) [c] ([$rawname$Tag], [$rawname$Abbr], [$rawname$Name], [$rawname$Desc], [$rawname$ParentTag], [Operator], [SortKey]);

/*
SELECT * FROM #$rawname$Stage;
*/

MERGE INTO [$SchemaName$].[$rawname$LookUp] [t]
USING
(
	SELECT
		[s].[$rawname$Tag],
		[s].[$rawname$Abbr],
		[s].[$rawname$Name],
		[s].[$rawname$Desc],
		[s].[SortKey],
		[s].[Operator]
	FROM
		#$rawname$Stage	[s]
) [s]([$rawname$Tag], [$rawname$Abbr], [$rawname$Name], [$rawname$Desc], [SortKey], [Operator])
	ON	([s].[$rawname$Tag]	= [t].[$rawname$Tag])

WHEN NOT MATCHED BY TARGET THEN
	INSERT(    [$rawname$Tag],     [$rawname$Abbr],     [$rawname$Name],     [$rawname$Desc],     [SortKey],     [Operator])
	VALUES([s].[$rawname$Tag], [s].[$rawname$Abbr], [s].[$rawname$Name], [s].[$rawname$Desc], [s].[SortKey], [s].[Operator])

WHEN MATCHED AND (
			([t].[$rawname$Abbr]	<> [s].[$rawname$Abbr])
		OR	([t].[$rawname$Name]	<> [s].[$rawname$Name])
		OR	([t].[$rawname$Desc]	<> [s].[$rawname$Desc])
		OR	([t].[SortKey]		<> [s].[SortKey])
		OR	([t].[Operator]		<> [s].[Operator])
	) THEN
	UPDATE
	SET [$rawname$Abbr]	= [s].[$rawname$Abbr],
		[$rawname$Name]	= [s].[$rawname$Name],
		[$rawname$Desc]	= [s].[$rawname$Desc],
		[SortKey]		= [s].[SortKey],
		[Operator]		= [s].[Operator];

/*
SELECT * FROM #$rawname$LookUp;
*/

MERGE INTO [$SchemaName$].[$rawname$Parent] [t]
USING
(
	SELECT
		[txId_$rawname$]	= [a].[txId_$rawname$],
		[ParentId]	= [p].[txId_$rawname$]
	FROM
		#$rawname$Stage	[s]
	INNER JOIN
		[$SchemaName$].[$rawname$LookUp]				[a]
			ON	([s].[$rawname$Tag]		=	[a].[$rawname$Tag])
	INNER JOIN
		[$SchemaName$].[$rawname$LookUp]				[p]
			ON	([s].[$rawname$ParentTag]	=	[p].[$rawname$Tag])

) [s]([txId_$rawname$], [ParentId])
	ON	([s].[txId_$rawname$]	= [t].[txId_$rawname$])

WHEN NOT MATCHED BY TARGET THEN
	INSERT(    [txId_$rawname$],     [ParentId])
	VALUES([s].[txId_$rawname$], [s].[ParentId])

WHEN MATCHED AND ([t].[ParentId]	<> [s].[ParentId]) THEN
	UPDATE
	SET [ParentId]	= [s].[ParentId]

WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

/*
SELECT * FROM [$SchemaName$].[$rawname$Parent];
SELECT * FROM [$SchemaName$].[$rawname$ParentHierarchy];
SELECT * FROM [$SchemaName$].[$rawname$ParentNest];
SELECT * FROM [$SchemaName$].[$rawname$Bridge];
*/

DROP TABLE IF EXISTS #$rawname$Stage;
GO
