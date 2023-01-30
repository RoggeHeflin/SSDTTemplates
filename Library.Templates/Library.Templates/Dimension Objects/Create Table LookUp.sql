CREATE TABLE [$SchemaName$].[$rawname$LookUp]
(
	[$rawname$Tag]							NVARCHAR(10)			NOT	NULL,	CONSTRAINT	[CL_$rawname$LookUp_AccountTag]				CHECK([$rawname$Tag]  <> N''),
	[$rawname$Abbr]							NVARCHAR(20)			NOT	NULL,	CONSTRAINT	[CL_$rawname$LookUp_AccountAbbr]			CHECK([$rawname$Abbr] <> N''),
	[$rawname$Name]							NVARCHAR(60)			NOT	NULL,	CONSTRAINT	[CL_$rawname$LookUp_AccountName]			CHECK([$rawname$Name] <> N''),
	[$rawname$Desc]							NVARCHAR(80)			NOT	NULL,	CONSTRAINT	[CL_$rawname$LookUp_AccountDesc]			CHECK([$rawname$Desc] <> N''),

	[SortKey]								INT						NOT	NULL,
	[Operator]								CHAR(1)					NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_Operator]				DEFAULT('+'),
																				CONSTRAINT	[CR_$rawname$LookUp_Operator]				CHECK([Operator] IN ('+', '-')),
	[Multiplier]							AS CONVERT(FLOAT, [Operator] + '1', 0)
											PERSISTED				NOT	NULL,

	[txId_$rawname$]							INT						NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,
	[txInserted]							DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]							VARBINARY(85)			NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUserExecuted]				NVARCHAR(128)			NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedUserExecuted]	DEFAULT(SUSER_SNAME()),
	[txInsertedUserOriginal]				NVARCHAR(128)			NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedHost]						NVARCHAR(128)			NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]					NVARCHAR(128)			NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedApplication]	DEFAULT(APP_NAME()),
	[txInsertedProcedure]					NVARCHAR(257)				NULL	CONSTRAINT	[DF_$rawname$LookUp_txInsertedProcedure]	DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txRowReplication]						UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT	[DF_$rawname$LookUp_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]							ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$LookUp]			PRIMARY KEY CLUSTERED([txId_$rawname$]	ASC),

	CONSTRAINT [UK_$rawname$LookUp_Tag]		UNIQUE NONCLUSTERED([$rawname$Tag]	ASC),
	CONSTRAINT [UK_$rawname$LookUp_Abbr]	UNIQUE NONCLUSTERED([$rawname$Abbr]	ASC),
	CONSTRAINT [UK_$rawname$LookUp_Name]	UNIQUE NONCLUSTERED([$rawname$Name]	ASC),
	CONSTRAINT [UK_$rawname$LookUp_Desc]	UNIQUE NONCLUSTERED([$rawname$Desc]	ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'$rawname$ look up values',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'table',		@level1name	= N'$rawname$LookUp';
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$LookUp_ReturnId]
ON [$SchemaName$].[$rawname$LookUp]
(
	[$rawname$Tag]	ASC
)
INCLUDE
(
	[txId_$rawname$]
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$LookUp_Ancestors]
ON [$SchemaName$].[$rawname$LookUp]
(
	[txId_$rawname$]		ASC
)
INCLUDE
(
	[$rawname$Name],
	[SortKey]
);