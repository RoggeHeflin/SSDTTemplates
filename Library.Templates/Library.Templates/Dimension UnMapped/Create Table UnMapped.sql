CREATE TABLE [$SchemaName$].[UnMapped]
(
	[UnMappedId]						INT						NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

	[MappingConstraint]					NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_MappingConstraint]	CHECK([MappingConstraint] <> ''),

	[SourceSchema]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_SourceSchema]		CHECK([SourceSchema] <> ''),
	[SourceTable]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_SourceTable]		CHECK([SourceTable] <> ''),
	[SourceColumn]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_SourceColumn]		CHECK([SourceColumn] <> ''),
	[SourceValue]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_SourceValue]		CHECK([SourceValue] <> ''),

	[MapSchema]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_MapSchema]			CHECK([MapSchema] <> ''),
	[MapTable]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_MapTable]			CHECK([MapTable] <> ''),
	[MapColumn]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [CL_UnMapped_MapColumn]			CHECK([MapColumn] <> ''),
	[MissingItems]						INT						NOT	NULL,

	[txInserted]						DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_UnMapped_txInserted]			DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]						VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_UnMapped_txInsertedSID]		DEFAULT(SUSER_SID()),
	[txInsertedUser]					NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_UnMapped_txInsertedUser]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]					NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_UnMapped_txInsertedHost]		DEFAULT(HOST_NAME()),
	[txInsertedApp]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_UnMapped_txInsertedApp]		DEFAULT(HOST_NAME()),
	[txRowReplication]					UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_UnMapped_txRowReplication]	DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]						ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_UnMapped]			PRIMARY KEY CLUSTERED([UnMappedId] ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Stores missing source values not mapped.',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'table',		@level1name	= N'UnMapped';