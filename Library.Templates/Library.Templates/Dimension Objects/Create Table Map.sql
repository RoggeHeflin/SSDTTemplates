CREATE TABLE [$SchemaName$].[$rawname$Map]
(
	[$rawname$Source]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_$rawname$Map_$rawname$Source]		CHECK([$rawname$Source] <> N''),
	[txId_$rawname$]							INT						NOT	NULL	CONSTRAINT [FK_$rawname$Map_$rawname$Lookup]		FOREIGN KEY ([txId_$rawname$])	REFERENCES [dim].[$rawname$LookUp]([txId_$rawname$]),

	[txInserted]							DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_$rawname$Map_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]							VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_$rawname$Map_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUser]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Map_txInsertedUser]			DEFAULT(SUSER_SNAME()),
	[txInsertedHost]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Map_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApp]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Map_txInsertedApp]			DEFAULT(HOST_NAME()),
	[txRowReplication]						UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_$rawname$Map_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]							ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$Map]			PRIMARY KEY CLUSTERED([$rawname$Source]	ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$Map_ReturnId]
ON [$SchemaName$].[$rawname$Map]
(
	[$rawname$Source]		ASC
)
INCLUDE
(
	[txId_$rawname$]
);