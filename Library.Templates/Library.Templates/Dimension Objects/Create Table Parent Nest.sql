CREATE TABLE [$SchemaName$].[$rawname$ParentNest]
(
	[txId_$rawname$]							INT						NOT	NULL	CONSTRAINT [FK_$rawname$ParentNest_$rawname$Lookup]		FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$])
																					CONSTRAINT [FK_$rawname$ParentNest_$rawname$Parent]		FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$Parent]([txId_$rawname$]),

	[NestLeft]									INT						NOT	NULL,
	[NestRight]									INT						NOT	NULL,	CONSTRAINT [CR_$rawname$ParentNest_Left_Right]			CHECK([NestLeft] < [NestRight]),
	[NestSpan]									INT						NOT	NULL,

	[txInserted]								DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txInserted]			DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]								VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txInsertedSID]		DEFAULT(SUSER_SID()),
	[txInsertedUser]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txInsertedUser]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txInsertedHost]		DEFAULT(HOST_NAME()),
	[txInsertedApp]								NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txInsertedApp]		DEFAULT(HOST_NAME()),
	[txRowReplication]							UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_$rawname$ParentNest_txRowReplication]	DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]								ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$ParentNest]			PRIMARY KEY CLUSTERED([txId_$rawname$] ASC),
	CONSTRAINT [UK_$rawname$ParentNest]			UNIQUE NONCLUSTERED([NestLeft] ASC, [NestRight] ASC),
	CONSTRAINT [UK_$rawname$ParentNest_Left]	UNIQUE NONCLUSTERED([NestLeft] ASC),
	CONSTRAINT [UK_$rawname$ParentNest_Right]	UNIQUE NONCLUSTERED([NestRight] ASC)
);