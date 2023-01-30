CREATE TABLE [$SchemaName$].[$rawname$ParentHierarchy]
(
	[txId_$rawname$]						INT						NOT	NULL	CONSTRAINT [FK_$rawname$ParentHierarchy_$rawname$Lookup]	FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$])
																				CONSTRAINT [FK_$rawname$ParentHierarchy_$rawname$Parent]	FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$Parent]([txId_$rawname$]),

	[Hierarchy]								SYS.HIERARCHYID			NOT	NULL,
	[HierarchyPath]							NVARCHAR(MAX)			NOT	NULL,
	[HierarchyDepth]						SMALLINT				NOT	NULL,
	[HierarchyDepthMax]						SMALLINT				NOT	NULL,
	[HierarchyIsLeaf]						BIT						NOT	NULL,
	[HierarchyChildren]						INT						NOT	NULL,
	[HierarchyItem]							INT						NOT	NULL,
	[HierarchyPrefix]						NVARCHAR(MAX)			NOT	NULL,

	[txInserted]							DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txInserted]			DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]							VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txInsertedSID]		DEFAULT(SUSER_SID()),
	[txInsertedUser]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txInsertedUser]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txInsertedHost]		DEFAULT(HOST_NAME()),
	[txInsertedApp]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txInsertedApp]		DEFAULT(HOST_NAME()),
	[txRowReplication]						UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_$rawname$ParentHierarchy_txRowReplication]	DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]							ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$ParentHierarchy]	PRIMARY KEY CLUSTERED([txId_$rawname$] ASC),
	CONSTRAINT [UK_$rawname$ParentHierarchy]	UNIQUE NONCLUSTERED([Hierarchy] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$ParentHierarchy_ParentNest]
ON [$SchemaName$].[$rawname$ParentHierarchy]
(
	[txId_$rawname$]			ASC,
	[HierarchyDepth]		ASC,
	[HierarchyChildren]		ASC,
	[HierarchyItem]			ASC
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$ParentHierarchy_Ancestors]
ON [$SchemaName$].[$rawname$ParentHierarchy]
(
	[txId_$rawname$]			ASC
)
INCLUDE
(
	[Hierarchy]
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$ParentHierarchy_Bridge]
ON [$SchemaName$].[$rawname$ParentHierarchy]
(
	[Hierarchy]				ASC
)
INCLUDE
(
	[txId_$rawname$]
);