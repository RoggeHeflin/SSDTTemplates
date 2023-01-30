CREATE TABLE [$SchemaName$].[$rawname$Bridge]
(
	[txId_$rawname$]						INT						NOT	NULL	CONSTRAINT [FK_$rawname$Bridge_$rawname$Lookup]				FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$])
																				CONSTRAINT [FK_$rawname$Bridge_$rawname$Parent]				FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$Parent]([txId_$rawname$]),
	[DescendantId]							INT						NOT	NULL	CONSTRAINT [FK_$rawname$Bridge_$rawname$Lookup_Descendant]	FOREIGN KEY ([DescendantId])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$])
																				CONSTRAINT [FK_$rawname$Bridge_$rawname$Parent_Descendant]	FOREIGN KEY ([DescendantId])	REFERENCES [$SchemaName$].[$rawname$Parent]([txId_$rawname$]),

	[Distance]								INT						NOT	NULL,

	[txInserted]							DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txInserted]					DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]							VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txInsertedSID]				DEFAULT(SUSER_SID()),
	[txInsertedUser]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txInsertedUser]				DEFAULT(SUSER_SNAME()),
	[txInsertedHost]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txInsertedHost]				DEFAULT(HOST_NAME()),
	[txInsertedApp]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txInsertedApp]				DEFAULT(HOST_NAME()),
	[txRowReplication]						UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_$rawname$Bridge_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]							ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$Bridge]			PRIMARY KEY CLUSTERED([txId_$rawname$] ASC, [DescendantId] ASC)
);
GO

CREATE INDEX [IX_$rawname$Bridge_Ancestors]
ON [$SchemaName$].[$rawname$Bridge]
(
	[DescendantId]	ASC
)
INCLUDE
(
	[txId_$rawname$]
);